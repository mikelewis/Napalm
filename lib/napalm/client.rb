require 'eventmachine'
module Napalm
  class Client < EventMachine::Connection
    def receive_data(data)
      if match = data.match(/^DO_WORK\s(.+)$/)

      end
    end

    def do(meth, *args)
      send_data("DO_WORK I WANT DATA")
    end

    #TODO
    def do_async(meth, *args)

    end


    class << self
      def init(opts={})
        opts.merge!({
          :ip => "127.0.0.1",
          :port => 11211
        })
        EM.run {
          EM.connect opts[:ip], opts[:port], Napalm::Worker
        }
      end
    end
  end
end
