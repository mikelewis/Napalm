require 'eventmachine'
module Napalm
  class Runner
    def self.go
      EM.epoll
      EM.run do
        EM.start_server Napalm::Settings::JOB_SERVER_IP, Napalm::Settings::JOB_SERVER_PORT, Napalm::JobServer
      end
    end
  end
end
