module Napalm
  module Utils
    def rand_str(len)
      chars = ('a'..'z').to_a+('A'..'Z').to_a
      (1..len).map{ chars[rand(chars.length)]  }.join;
    end
  end
end
