#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

class MyWorker < Napalm::Worker

end

w = MyWorker.do_work
