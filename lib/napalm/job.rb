module Napalm
  class Job
    include Napalm::Utils
    attr_accessor :client, :result, :error
    attr_reader :meth, :args,:sync, :id
    def initialize(meth, args, opts={})
      #@id = UUID.new.generate
      # Max File acccess limits per Operating System settings. =/
      @time = Time.now.to_i
      @id = "#{@time}#{rand_str(20)}"
      @meth = meth
      @args = args
      @sync = opts[:sync] || false
      @error = false
    end

    def quick_stats
      {
        :meth => @meth,
        :args => @args,
        :sync => @sync,
        :id => @id,
        :time => @time
      }
    end

    def unmarshal_args!
      begin
        @args = Napalm::Utils.load_data(@args)
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

    def set_error!(error)
      @error = true
      @result = error
      self
    end
  end
end
