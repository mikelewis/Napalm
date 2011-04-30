require 'napalm'

class MyWorker < Napalm::Worker

end

w = MyWorker.do_work
