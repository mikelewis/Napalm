require 'eventmachine'
require 'set'

module Napalm
  module JobServer
    include Napalm::Utils::ObjectProtocol
    @@workers = Set.new
    @@worker_methods = {}
    @@log = []
    @@current_jobs = {}

    def post_init
      @buffer = nil
      @port, *ip_parts = get_peername[2,6].unpack "nC4"
      @ip = ip_parts.join('.')
      @is_client = false
      @is_worker = false

      @commands = {
        :add_worker => 
        {
          :route => proc {|methods| add_worker(methods) if methods.is_a?(Array) }
        },
          :get_workers => 
        {
          :route => proc { get_workers }
        },
          :do_work =>
        {
          :route => proc {|job| do_work(job) }
        },
          :done_working =>
        {
          :route => proc { |job| done_working(job) }
        }
      }
    end

    def receive_object(payload)
      unless payload.cmd && @commands.include?(payload.cmd)
        @buffer << Napalm::Codes::BAD_SERVER_COMMAND and return
      end
      result = @commands[payload.cmd][:route].call(payload.data)
      flush_buffer unless result
    end

    def unbind
      #remove worker
      if @@workers.delete?(self)
        @@worker_methods.each do |meth, workers|
          workers.delete(self)
        end
      end
      @@current_jobs.delete_if{|k,v| v[:client] == self} if client?
    end

    def to_s
      "#{@ip}:#{@port}"
    end

    private

    def client?
      @is_client
    end

    def worker?
      @is_worker
    end
    #Universal Method

    def flush_buffer
      if @buffer
        send_object(@buffer)
        @buffer = nil
      else
        send_object(Payload.new(:result, Napalm::Codes::OK)) if client?
      end
    end

    #Worker Method
    def add_worker(methods)
      @@workers << self
      @is_worker = true
      methods.each{|m| (@@worker_methods[m] ||= Set.new) << self  }
      @@log << "Added #{@ip}:#{@port} (#{methods.join(",")}) to worker list"
    end

    #Universal Method
    def get_workers
      @buffer << @@worker_methods.inspect
    end

    #Client Method

    def do_work(job)
      @is_client = true
      unless @@worker_methods.include?(job.meth) && !@@worker_methods[job.meth].empty?
        @buffer = Payload.new(:result, job.set_error!(Napalm::Codes::NO_AVAILABLE_WORKERS)) and return
      end
      job.set_client!(@ip, @port)
      worker = next_worker(job.meth)
      @@current_jobs[job.id] = {:client => self, :worker => worker}
      #Napalm::Persistance.add(job)
      worker.send_object(job)

      #if true, it will not flush the buffer because the client is waiting for the result
      job.sync
    end

    #Client Method
    def next_worker(meth)
      #need to implement, currently random
      workers_array = @@worker_methods[meth].to_a
      rand_index = rand(workers_array.length)
      workers_array[rand_index]
    end

    #Worker Method
    def done_working(job)
      if !(current_job = @@current_jobs.delete(job.id)).nil?
        current_job[:client].send_object(Payload.new(:result, job))
      end
      #Napalm::Persistance.remove(job)
    end
  end
end
