#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')


Napalm::Client.do_async(:this)

Napalm::Client.do_async(:loop_lists, [1,2,3], [4,5,6])
