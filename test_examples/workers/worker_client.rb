#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

class WorkerClient < Napalm::Worker
  worker_methods :compute_odds 

  def compute_odds(s, e)
    left = Napalm::Client.do(:dist_compute_odds, s, e/2)
    right = Napalm::Client.do(:dist_compute_odds, (e/2)+1, e)
    results = left + right
  end
 
end

WorkerClient.do_work
