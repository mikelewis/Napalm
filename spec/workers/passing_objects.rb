#!/usr/bin/env ruby
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')
require File.join(File.dirname(f), '..', 'helper_objects')

class PersonWorker < Napalm::Worker
  worker_methods :print_age_x_times, :calculate_next_age

  def print_age_x_times(person, x)
    x.times{ person.print_age }
  end

  def calculate_next_age(person)
    person.age + 1
  end
end

PersonWorker.do_work
