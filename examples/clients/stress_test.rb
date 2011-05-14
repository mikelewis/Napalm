#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')



results = []
Napalm::Client.start do |client|
  start = Time.now
  10_000.times do |n|
    client.do_async(:add_me, 1, n){|result| results << result}
  end
  puts Time.now - start
end

p results.size
