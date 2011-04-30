require 'eventmachine'
module Napalm
  class Worker < EventMachine::Connection
    def initialize(methods)
      #register worker with job server
      send_data("ADD_WORKER #{methods.join(" ")}")
    end
    def receive_data(data)
      return unless data.start_with?("Payload:")
      data = Marshal.load(data.split("Payload:")[1])
      meth, args = data
      if respond_to?(meth)
        if args.empty?
          send(meth)
        else
          send(meth, *args)
        end
      end
      send_data("DONE_WORKING")
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
          EM.connect opts[:ip], opts[:port], self, @methods
        }
      end
    end
  end
end
