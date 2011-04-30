require 'eventmachine'
module Napalm
  class Worker < EventMachine::Connection
    def initialize(methods)
      send_data("ADD_WORKER #{methods.join(" ")}")
    end
    def receive_data(data)
      if match = data.match(/^DO_WORK\s(.+)$/)
        p "Recieved work"
      end
    end

    class << self
      def worker_methods(*meths)
        @methods = meths
      end
      def do_work(opts={})
        raise "You need atleast one worker method" unless @methods
        opts.merge!({
          :ip => "127.0.0.1",
          :port => 11211
        })
        EM.run {
          #should checkout for timeout
          EM.connect opts[:ip], opts[:port], Napalm::Worker, @methods
        }
      end
    end
  end
end
