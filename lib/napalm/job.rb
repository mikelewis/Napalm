module Napalm
  class Job
    include Napalm::Utils
    attr_reader :meth, :args, :client
    def initialize(meth, args, client)
      #@id = UUID.new.generate
      # Max File acccess limits per Operating System settings. =/
      @time = Time.now.to_i
      @id = "#{@time}#{rand_str(20)}"
      @meth = meth
      @args = args
      @client = client
    end

    def unmarshal_args!
      begin
        @args = Marshal.load(@args)
      rescue ArgumentError => e
        return Napalm::Codes::INVALID_WORKER_ARGUMENTS
      end
    end

    def with_marshalled_args
      @args = Marshal.dump(@args)
      self
    end
  end
end
