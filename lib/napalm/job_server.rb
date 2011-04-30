require 'set'
module Napalm
  module JobServer
    @@workers = Set.new

    def post_init
      @buffer = ""
      @port, *ip_parts = get_peername[2,6].unpack "nC4"
      @ip = ip_parts.join('.')


      @commands = {
        :add_worker => 
        {
          :regex => /^ADD_WORKER$/,
          :route => proc { add_worker }
        },
        :get_workers => {
          :regex => /^GET_WORKERS$/,
          :route => proc { get_workers }
        },
        :do_work =>
        {
          :regex => /^DO_WORK\s(.+)$/,
          :route => proc {|w| do_work(w)}
        }
      }

    end

    def receive_data(data)
      execute_command(data.chomp)

      flush_buffer
    end

    def unbind
      #remove worker
      @@workers.delete(:ip=>@ip, :port=>@port)
    end

    private
    def flush_buffer
      unless @buffer.empty?
        send_data(@buffer)
        @buffer = ""
      end
    end

    def add_worker
      @@workers << {:ip=>@ip, :port=>@port}
      @buffer << "Added #{@ip}:#{@port} to worker list"
    end

    def get_workers
      @buffer << @@workers.to_a.inspect
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
