#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')


def primes_gen
  results = []
  Napalm::Client.start do |client|
    (10_000..11_000).each do |n|
      client.do_async(:is_prime?, n){|result| results <<  n if result}
    end
  end
  return results.size
end

p primes_gen
