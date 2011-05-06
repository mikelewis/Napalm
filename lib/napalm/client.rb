require 'eventmachine'
module Napalm
  class Client < EventMachine::Connection
    include EM::P::ObjectProtocol

    attr_reader :result
    def initialize(opts={})
      super
      @method = opts[:meth]
      @args = opts[:args]
      @sync = opts[:sync] || false
      @in_worker = opts[:in_worker] || false
      @result = nil
      send_object(Napalm::Payload.new(:do_work, Job.new(@method, Marshal.dump(@args),:sync=>@sync )))
      self
    end

    def receive_object(obj)
      @result = if obj.is_a?(Napalm::Job)
        obj.result
      else
        obj.data
      end
      EventMachine::stop_event_loop unless @in_worker
    end

    class << self
      def init(opts={})
        @job_ip = opts[:ip] || Napalm::Settings::JOB_SERVER_IP
        @job_port = opts[:port] || Napalm::Settings::JOB_SERVER_PORT
      end

      def do(*args)
        do_request(args, true)
      end

      def do_async(*args)
        do_request(args, false)
      end

      private

      def do_request(args, sync=false)
        if EventMachine.reactor_running?
          connection = gen_connection(*grab_method_and_arguments(args), :in_worker=>true, :sync=>sync)
          # we are in worker reactor
          srv = connection.call
        else
          connection = gen_connection(*grab_method_and_arguments(args), :sync=>sync)
          srv = run_em(connection)
        end
        until srv.result do end
        srv.result

      end

      def run_em(connection)
        srv = nil
        EM.run {
          srv = connection.call
        }
        srv
      end

      def gen_connection(meth, arguments, opts={})
        sync = opts[:sync] || false
        in_worker = opts[:in_worker] || false
        lambda {EM.connect @job_ip || Napalm::Settings::JOB_SERVER_IP, @job_port || Napalm::Settings::JOB_SERVER_PORT, self, :meth => meth, :args => arguments, :sync=>sync, :in_worker=>in_worker }
      end

      def grab_method_and_arguments(args)
        [args.shift, args]
      end

      end
    end
  end
