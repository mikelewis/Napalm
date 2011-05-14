#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

class ComputeOddsWorker < Napalm::Worker
  worker_methods :dist_compute_odds
   def dist_compute_odds(s, e)
      (s..e).select{|x| !(x%2).zero?}
   end
end

ComputeOddsWorker.do_work
