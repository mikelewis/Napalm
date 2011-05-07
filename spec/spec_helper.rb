f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', 'lib', 'napalm')
require 'helper_objects'

def launch_job_server
  @job_pid = spawn("../bin/napalm")
  sleep 1
end

def launch_worker(name)
  pid = spawn("./workers/#{name}.rb")
  sleep 1
  pid
end
