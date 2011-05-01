#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

c = Napalm::Client.new
100.times do
  c.do_async(:lr)
end
