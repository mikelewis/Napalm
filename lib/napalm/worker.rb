require 'eventmachine'
module Napalm
  class Worker < EventMachine::Connection
    def receive_data(data)
      puts "yo"
    end

    class << self
      def do_work
        EM.run {
          EM.connect '127.0.0.1', 11211, Napalm::Worker
        }
      end
    end
  end
end
