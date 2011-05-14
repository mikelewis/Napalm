#testing
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

class Person
  def initialize
    @age = 20
  end
  def print_age
    p @age
  end
end

class PersonWorker < Napalm::Worker
  worker_methods :print_age_x_times

  def print_age_x_times(person, x)
    x.times{ person.print_age }
  end
end

PersonWorker.do_work
