#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

MAX = 10

Napalm::Client.start do |client|
  #(10_00...(10_000 + MAX)).each do |n|
  (10..50).each do |n|
    client.do_async(:is_prime?, n) {|result| results << n if result}
  end
end

p results.size
