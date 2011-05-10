module Napalm
  class Job
    include Napalm::Utils
    attr_accessor :client, :result
    attr_reader :meth, :args,:sync, :id, :has_callback
    def initialize(meth, args, opts={})
      #@id = UUID.new.generate
      # Max File acccess limits per Operating System settings. =/
      @time = Time.now.to_i
      @id = "#{@time}#{rand_str(20)}"
      @meth = meth
      @args = args
      @sync = opts[:sync] || false
      @has_callback = opts[:callback] || false
    end

    def quick_stats
      {
        :meth => @meth,
        :args => @args,
        :sync => @sync,
        :id => @id,
        :time => @time,
        :has_callback => @hash_callback
      }
    end

    def unmarshal_args!
      begin
        @args = Marshal.load(@args)
      rescue ArgumentError => e
        return Napalm::Codes::INVALID_WORKER_ARGUMENTS
      end
    end

    def set_result!(val)
      @result = val
      self
    end

    def set_client!(ip, port)
      @client = {:ip=>ip, :port=>port}
      self
    end
  end
end
