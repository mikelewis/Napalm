require 'redis'
module Napalm
  class Persistance
    class << self
      def namespace
        "napalm"
      end
      def set
        @_set ||= Redis.new(:thread_safe=>true)
      end
      def set_name
        "#{namespace}:jobs"
      end
      def add(job)
        set.sadd(set_name, job_to_persistant(job))
      end

      def remove(job)
        set.srem(set_name, job_to_persistant(job))
      end

      private

      def job_to_persistant(job)
        Marshal.dump(job.quick_stats)
      end
    end
  end
end
