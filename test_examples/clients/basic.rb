#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

c = Napalm::Client.new

100.times do
  c.do_async(:this)
end
10.times do
  c.do_async(:loop_lists, [1,2,3], [4,5,6])
end
