require 'eventmachine'
require 'socket'
module Napalm
  class Client < EventMachine::Connection
    include EM::P::ObjectProtocol

    attr_reader :result
    def initialize(opts={})
      super
      @method = opts[:meth]
      @args = opts[:args]
      @sync = opts[:sync] || false
      @result = nil
      send_object(Napalm::Payload.new(:do_work, Job.new(@method, Marshal.dump(@args),:sync=>@sync )))
    end

    def receive_object(obj)
      @result = obj.data
      EventMachine::stop_event_loop
    end

    private

    class << self
      def init(opts={})
        @job_ip = opts[:ip] || Napalm::Settings::JOB_SERVER_IP
        @job_port = opts[:port] || Napalm::Settings::JOB_SERVER_PORT
      end

      def do(*args)
        run_em(gen_connection(*grab_method_and_arguments(args), true))
      end

      def do_async(*args)
        run_em(gen_connection(*grab_method_and_arguments(args)))
      end

      private
      
      def run_em(connection)
        srv = nil
        EM.run {
          srv = connection.call
        }
        srv.result if srv
      end

      def gen_connection(meth, arguments, sync=false)
         lambda {EM.connect @job_ip || Napalm::Settings::JOB_SERVER_IP, @job_port || Napalm::Settings::JOB_SERVER_PORT, self, :meth => meth, :args => arguments, :sync=>sync }
      end

      def grab_method_and_arguments(args)
        [args.shift, args]
      end

      end
    end
  end
