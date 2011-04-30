require 'set'
module Napalm
  module JobServer
    @@workers = Set.new
    @@worker_methods = {}
    @@log = []

    def post_init
      @buffer = ""
      @port, *ip_parts = get_peername[2,6].unpack "nC4"
      @ip = ip_parts.join('.')
      @busy = false
      #@connection = {:ip => ip, :port=>port, :busy => false}

      @commands = {
        :add_worker => 
        {
          :regex => /^ADD_WORKER\s(.+)$/,
          :route => proc {|x| add_worker(*x.split(" ")) }
        },
        :get_workers => {
          :regex => /^GET_WORKERS$/,
          :route => proc { get_workers }
        },
        :do_work =>
        {
          :regex => /^DO_WORK\s(.+)$/,
          :route => proc {|w|
                      do_work(*w.split(" "))
                    }
        },
          :done_working =>
          {
            :regex => /^DONE_WORKING$/,
            :route => proc { @busy=false }
          }
      }

    end

    def receive_data(data)
      execute_command(data.chomp)

      flush_buffer
    end

    def unbind
      #remove worker
      if @@workers.delete?(self)
        @@worker_methods.each do |meth, workers|
          workers.delete(self)
        end
      end
    end

    def to_s
      "#{@ip}:#{@port}"
    end

    def busy?
      @busy
    end

    def busy=(val)
      @busy = val
    end

    private
    def flush_buffer
      unless @buffer.empty?
        send_data(@buffer)
        @buffer = ""
      end
    end

    def add_worker(*methods)
      @@workers << self
      methods.each{|m| (@@worker_methods[m.to_sym] ||= Set.new) << self  }
      @@log << "Added #{@ip}:#{@port} (#{methods.join(",")}) to worker list"
      p @@worker_methods
    end

    def get_workers
      @buffer << @@worker_methods.inspect
    end

    def do_work(*payload)
      meth = payload.shift.to_sym
      unless @@worker_methods.include?(meth) && !@@worker_methods[meth].empty?
        @buffer << "No worker can compute this task"
        return
      end
      worker = @@worker_methods[meth].find{|worker| !worker.busy?}
      if worker
        p "Found Worker #{worker}"
        worker.busy = true
        worker.send_data("Payload:#{Marshal.dump([meth, payload])}")
      else
        p "worker busy"
        #add to queue
      end

    end

    def execute_command(cmd)
      if command_desc = @commands.find{|c,v| v[:regex].match(cmd)}.to_a[1]
        command_desc[:route].call(Regexp.last_match[1])
      else
        @buffer << "Bad Command"
      end
    end
  end
end
