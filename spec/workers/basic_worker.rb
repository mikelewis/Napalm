#!/usr/bin/env ruby
f = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
require File.join(File.dirname(f), '..', '..', 'lib', 'napalm')

class MyWorker < Napalm::Worker
  worker_methods :this, :that, :lr, :loop_lists, :add_me
  worker_methods :create_odds, :long_running_1
  def this
    p "Im doing this!"
  end

  def that
    p "I'm doing that!"
  end
  def lr
    p "Time to sleep"
    sleep 20
    p "Done sleeping"
  end

  def loop_lists(list, another_list)
    (list+another_list).each{|e| puts e}
  end

  def dont_call_me
    p "You weren't supposed to call me via job server!"
  end

  def add_me(x, y)
    x+y
  end

  def create_odds(upto)
    (1..upto).select{|x| !(x%2).zero? }
  end

  def long_running_1(echo, time)
    sleep time
    echo
  end

end

MyWorker.do_work
