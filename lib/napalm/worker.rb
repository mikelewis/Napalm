require 'eventmachine'
require 'socket'
require 'thread'

module Napalm
  class Worker < EventMachine::Connection
    include EM::P::ObjectProtocol
    @@job_queue = ::Queue.new

    def initialize
      super
      send_object(Napalm::Payload.new(:add_worker, self.class.worker_meths))
    end

    def receive_object(obj)
      @@job_queue << obj
      do_job
    end

    private

    def do_job
      EM.defer do
        job = @@job_queue.pop
        untainted_job = job.clone
        result = nil
        unless job.unmarshal_args! == Napalm::Codes::INVALID_WORKER_ARGUMENTS
          if self.class.worker_meths.include?(job.meth) && respond_to?(job.meth)
            begin
              result = if job.args.empty?
                send(job.meth)
              else
                send(job.meth, *job.args)
              end
            rescue ArgumentError
              p "bad data"
              #bad data
            end
          end
        else
          # handle invalid worker arguments
          # Maybe add to an error queue in Redis?
        end
        completed_job(untainted_job.set_result!(result))
      end
    end

    def completed_job(job)
      send_object(Napalm::Payload.new(:done_working, job))
    end

    class << self
      attr_reader :worker_meths
      def worker_methods(*meths)
        @worker_meths = [*(@worker_meths||=[]), *meths]
      end

      def do_work(opts={})
        raise "You need atleast one worker method" unless @worker_meths
        #job server settings
        opts.merge!({
          :ip => Napalm::Settings::JOB_SERVER_IP,
          :port => Napalm::Settings::JOB_SERVER_PORT
        })
        EM.run {
          srv = EM.connect opts[:ip], opts[:port], self
        }
      end
    end
  end
end
