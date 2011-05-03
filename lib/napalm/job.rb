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
  end
end
