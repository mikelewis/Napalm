require 'eventmachine'
require 'socket'
module Napalm
  class Client
    include EM::P::ObjectProtocol
    def initialize(opts={})
      @job_ip = opts[:ip] || "127.0.0.1"
      @job_port = opts[:port] || 11211
    end

    #TODO
    def recieve_object(obj)
      p "Received Object"
    end

    #TODO
    def do(*args)
      
    end

    #Example:
    # client = Napalm::Client.new
    # client.do_asyn(:say_hi, "arg1", "arg2", 3)
    def do_async(*args)
      meth = args.shift
      payload = Napalm::Payload.new(:do_work, Job.new(meth, args, {}))
      data = Marshal.dump(payload)
      @sock ||= TCPSocket.open(@job_ip, @job_port)
      @sock.send([data.respond_to?(:bytesize) ? data.bytesize : data.size, data].pack('Na*'), 0)
      ret_data = @sock.recv(1024)
      raise "No Available Workers for #{meth}" if ret_data == Napalm::Codes::NO_AVAILABLE_WORKERS
      true if ret_data == Napalm::Codes::OK

    end
    end
  end
