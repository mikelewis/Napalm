#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

class MyWorker < Napalm::Worker
  worker_methods :this, :that, :long_running, :lr, :dummy
  def this
    p "Im doing this!"
  end

  def that
    p "I'm doing that!"
  end

  def dummy
    "do not print me"
  end

  def long_running
    p "Time to sleep"
    sleep 10
    p "Done sleeping"
  end
  def lr
    p "Time to sleep"
    sleep 20
    p "Done sleeping"
  end
end

MyWorker.do_work
