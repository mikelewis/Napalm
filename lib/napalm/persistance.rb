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
        set.sadd(set_name, Marshal.dump(job))
      end

      def remove(job)
        set.srem(set_name, Marshal.dump(job))
      end
    end
  end
end
