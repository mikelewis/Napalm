require 'active_support'
require 'eventmachine'
module Napalm
  module Utils
    def rand_str(len)
      ActiveSupport::SecureRandom.hex(len)
    end
    def dump_data(x)
      Marshal.dump(x)
    end

    def load_data(x)
      Marshal.load(x)
    end

    module_function :dump_data, :load_data


    module ObjectProtocol
    include EM::P::ObjectProtocol
      #override seralizer here
    end

  end
end
