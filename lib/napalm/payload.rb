module Napalm
  class Payload
    attr_reader :cmd, :data
    def initialize(cmd, data=nil)
      @cmd = cmd
      @data = data
    end
  end
end
