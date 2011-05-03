require 'eventmachine'
require 'set'
module Napalm
  module JobServer
   include EM::P::ObjectProtocol
    @@workers = Set.new
    @@worker_methods = {}
    @@clients = Set.new
    @@log = []
    
    def post_init
      @buffer = ""
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

    #def receive_data(data)
    #  execute_command(data.chomp)
    #
    #  flush_buffer
    #end

    def receive_object(payload)
      unless payload.cmd && @commands.include?(payload.cmd)
        @buffer << Napalm::Codes::BAD_SERVER_COMMAND and return
      end
      route = @commands[payload.cmd][:route].call(payload.data)
      flush_buffer
    end

    def unbind
      #remove worker
      if @@workers.delete?(self)
        @@worker_methods.each do |meth, workers|
          workers.delete(self)
        end
      end
      @@clients.delete(self)
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
      if @buffer.empty?
        send_data("OK") if client?
      else
        send_data(@buffer)
        @buffer = ""
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
        @buffer << Napalm::Codes::NO_AVAILABLE_WORKERS and return
      end
      worker = next_worker(job.meth)
      Napalm::Persistance.add(job)
      worker.send_object(job)
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
      Napalm::Persistance.remove(job)
    end
  end
end
