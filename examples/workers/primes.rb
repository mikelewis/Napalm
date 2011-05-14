#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

class PrimeWorker < Napalm::Worker
  worker_methods :is_prime?
  #so slow, but brings home the point
  def is_prime?(num)
    ('1' * num) !~ /^1?$|^(11+?)\1+$/
  end
end

PrimeWorker.do_work
