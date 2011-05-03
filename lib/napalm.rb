#ugly but needed
$:.unshift(File.dirname(__FILE__))


module Napalm
end

require 'napalm/codes'
require 'napalm/settings'
require 'napalm/utils'
require 'napalm/persistance'
require 'napalm/payload'
require 'napalm/job'
require 'napalm/job_server'
require 'napalm/worker'
require 'napalm/client'
require 'napalm/runner'
