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


Napalm::Client.do_async(:print_age_x_times, Person.new, 5)
