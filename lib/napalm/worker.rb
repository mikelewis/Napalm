require 'eventmachine'
module Napalm
  class Worker < EventMachine::Connection
    def initialize
      send_data("ADD_WORKER")
    end
    def receive_data(data)
      if match = data.match(/^DO_WORK\s(.+)$/)

      end
    end

    class << self
      def do_work(opts={})
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
