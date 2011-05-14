#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

Napalm::Client.init
p Napalm::Client.do(:create_odds, 100000)
