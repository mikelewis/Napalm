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


      def start(&blk)
        raise "You need to pass in a block" unless block_given?
        EM.run {
          conn = EM.connect @job_ip || Napalm::Settings::JOB_SERVER_IP, @job_port || Napalm::Settings::JOB_SERVER_PORT, Napalm::Bulkcall
          conn.run_block(blk)
        }
      end



      private

      def do_callback(callback, job_id)
        # check if reactor is running for worker reactor
        connection = gen_connection(:callback=>callback, :job_id=>job_id, :handler=>Napalm::Callback)
        if EM.reactor_running?
          connection.call
        else
          run_em(connection)
        end
      end

      def do_request(args, opts={})
        opts[:sync] ||= false
        opts[:meth], opts[:args] = grab_method_and_arguments(args)
        if EventMachine.reactor_running?
          opts[:in_worker] = true
          connection = gen_connection(opts)
          # we are in worker reactor
          srv = connection.call
        else
          connection = gen_connection(opts)
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

      def gen_connection(opts={})
        handler = opts[:handler] || self
        lambda {EM.connect @job_ip || Napalm::Settings::JOB_SERVER_IP, @job_port || Napalm::Settings::JOB_SERVER_PORT, handler, opts}
      end

      def grab_method_and_arguments(args)
        [args.shift, args]
      end


      end

    end

    class Callback < EventMachine::Connection
      include EM::P::ObjectProtocol
      def initialize(opts={})
        super
        raise("Need to add a callback to use Napalm::Callback") unless opts[:callback]
        raise("Need to add a job_id to use Napalm::Callback") unless opts[:job_id]
        @callback = opts[:callback]

        send_object(Napalm::Payload.new(:add_callback, opts[:job_id]))
      end

      def receive_object(obj)
        @callback.call(obj.data.result)
        EM.stop_event_loop unless EM.connection_count > 0
      end
    end

    class Bulkcall < EventMachine::Connection
      include EM::P::ObjectProtocol
      def initialize
        super
        @sync_jobs = {}
        @jobs = Set.new
        @callbacks = {}
      end

      def run_block(block)
        block.call(self)
        #EM.stop if @callbacks.empty?
      end



      def do_async(meth, *args, &blk)
        job = Job.new(meth, Marshal.dump(args), :sync =>false, :callback => block_given?)
        @callbacks[job.id] = blk if block_given?
        send_object(Napalm::Payload.new(:do_work, job))
      end

      def receive_object(obj)
        if obj.data.is_a?(Napalm::Job)
          job = obj.data
          if callback = @callbacks.delete(job.id)
            callback.call(job.result)
          end
          EM.stop if @callbacks.empty? && @sync_jobs.empty?
        end
      end
    end
  end
