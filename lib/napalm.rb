#ugly but needed
$:.unshift(File.dirname(__FILE__))

module Napalm
  # Your code goes here...
end

require 'napalm/queue'
require 'napalm/job_server'
require 'napalm/worker'
require 'napalm/client'
require 'napalm/runner'
