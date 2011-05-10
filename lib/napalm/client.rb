require 'eventmachine'
module Napalm
  class Client < EventMachine::Connection
    include EM::P::ObjectProtocol

    attr_reader :result, :job
    def initialize(opts={})
      super
      @method = opts[:meth]
      @args = opts[:args]
      @sync = opts[:sync] || false
      @in_worker = opts[:in_worker] || false
      @result = nil
      @job = Job.new(@method, Marshal.dump(@args), :sync =>@sync, :callback => !!opts[:callback])

      send_object(Napalm::Payload.new(:do_work, @job))
      self
    end

    def receive_object(obj)
      data = obj.data
      @result = (data.is_a?(Napalm::Job)) ? data.result : data
      EventMachine::stop_event_loop unless @in_worker

    end

    class << self
      attr_reader :job_ip, :job_port
      def init(opts={})
        @job_ip = opts[:ip] || Napalm::Settings::JOB_SERVER_IP
        @job_port = opts[:port] || Napalm::Settings::JOB_SERVER_PORT
      end

      def do(*args)
        result, ending_connecting = do_request(args, :sync=>true)
        result
      end

      def do_async(*args, &blk)
        opts = {}
        if block_given?
          opts[:callback] = blk
        end
        result, ending_connection = do_request(args, opts)

        Thread.new do
          do_callback(blk, ending_connection.job.id)
        end if block_given? && result == Napalm::Codes::OK

        result
      end

      private

      def do_callback(callback, job_id)
        # check if reactor is running for worker reactor
          EM.run {
            EM.connect(@job_ip || Napalm::Settings::JOB_SERVER_IP, @job_port || Napalm::Settings::JOB_SERVER_PORT, Napalm::Callback, callback, job_id)
          }

      end

      def do_request(args, opts={})
        opts[:sync] ||= false
        if EventMachine.reactor_running?
          opts[:in_worker] = true
          connection = gen_connection(*grab_method_and_arguments(args), opts)
          # we are in worker reactor
          srv = connection.call
        else
          connection = gen_connection(*grab_method_and_arguments(args), opts)
          srv = run_em(connection)
        end
        until srv.result do end
        result = srv.result
        [result, srv]
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
        callback = opts[:callback]
        lambda {EM.connect @job_ip || Napalm::Settings::JOB_SERVER_IP, @job_port || Napalm::Settings::JOB_SERVER_PORT, self, :meth => meth, :args => arguments, :sync=>sync, :in_worker=>in_worker, :callback=>callback}
      end

      def grab_method_and_arguments(args)
        [args.shift, args]
      end

      end
    end

    class Callback < EventMachine::Connection
      include EM::P::ObjectProtocol
      def initialize(callback, job_id)
        super
        @callback = callback

        send_object(Napalm::Payload.new(:add_callback, job_id))
      end

      def receive_object(obj)
        @callback.call(obj.data.result)
        EM.stop_event_loop
      end
    end
  end
