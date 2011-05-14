#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')


Napalm::Client.start do |client|
  client.do_async(:this){|result| p result}
  client.do_async(:loop_lists, [1,2,3], [4,5,6]){|result| p result}
end
