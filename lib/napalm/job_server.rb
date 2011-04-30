require 'set'
module Napalm
  module JobServer
    @@workers = Set.new
    @@worker_methods = {}

    def post_init
      @buffer = ""
      @log = []
      port, *ip_parts = get_peername[2,6].unpack "nC4"
      ip = ip_parts.join('.')
      @connection = {:ip => ip, :port=>port, :busy => false}

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
        }
      }

    end

    def receive_data(data)
      execute_command(data.chomp)

      flush_buffer
    end

    def unbind
      #remove worker
      if @@workers.delete?(@connection)
        @@worker_methods.each do |meth, workers|
          workers.delete(@connection)
        end
      end
    end

    private
    def flush_buffer
      unless @buffer.empty?
        send_data(@buffer)
        @buffer = ""
      end
    end

    def add_worker(*methods)
      @@workers << @connection
      methods.each{|m| (@@worker_methods[m.to_sym] ||= Set.new) << @connection  }
      @buffer << "Added #{@connection[:ip]}:#{@connection[:port]} (#{methods.join(",")}) to worker list"
      p @@worker_methods
    end

    def get_workers
      @buffer << @@workers.to_a.inspect
    end

    def do_work(payload)
      meth = payload.shift
      args = payload
      worker = @@worker_methods[meth.to_sym].find{|worker| !worker[:busy]}

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
