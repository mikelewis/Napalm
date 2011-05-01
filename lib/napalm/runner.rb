require 'eventmachine'
module Napalm
  class Runner
    def self.go
      EM.epoll
      EM.run do
        EM.start_server "127.0.0.1", 11211, Napalm::JobServer
      end
    end
  end
end
