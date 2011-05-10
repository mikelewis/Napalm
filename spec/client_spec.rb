require File.dirname(__FILE__) + '/spec_helper'

describe Napalm::Client do

  before(:all) do
    @job_pid = launch_job_server
  end

  after(:all) do
    Process.kill("HUP", @job_pid)
  end

  it "should include EM::P::ObjectProtocol" do
    Napalm::Client.include?(EM::P::ObjectProtocol)
  end

  it "should respond to do" do
    Napalm::Client.respond_to?(:do).should eq(true)
    end

    it "should respond to do_async" do
      Napalm::Client.respond_to?(:do_async).should eq(true)
    end

    context "Client interacting with basic worker" do
      before(:all) do
        @worker1_pid = launch_worker("basic_worker")
      end

      after(:all) do
        Process.kill("HUP", @worker1_pid)
      end

      it "should return succesfully for a valid async call" do
        Napalm::Client.do_async(:this).should eq(Napalm::Codes::OK)
      end

      it "should return a value with a sync call" do
        Napalm::Client.do(:add_me, 5, 100).should eq(105)
      end

      it "should not beable to call a worker method that does not exist for async" do
        Napalm::Client.do_async(:some_function, [1,2]).should eq(Napalm::Codes::NO_AVAILABLE_WORKERS)
      end

      it "should not beable to call a worker method that does not exist for sync" do
        Napalm::Client.do(:some_function, [1,2]).should eq(Napalm::Codes::NO_AVAILABLE_WORKERS)
      end

      it "should be able to add a callback to async calls" do
        bob = "mike"
        r = Napalm::Client.do_async(:add_me, 20, 20) do |result|
          result.should eq(40)
        end
        sleep 5 #emulate work
      end

      it "should be able receive initial response when adding a callback" do
        call = Napalm::Client.do_async(:add_me, 20, 20) do |result|
          p "GOT RESULT2! #{result}"
        end
        sleep 4
        call.should eq(Napalm::Codes::OK)

      end
    end

    context "Client interacting with passing objects" do
      before(:all) do 
        @worker_pid = launch_worker("passing_objects")
      end

      after(:all) do 
        Process.kill("HUP", @worker_pid)
      end

      it "should be able to pass objects to worker" do
        Napalm::Client.do(:calculate_next_age, Person.new).should eq(21)
      end
    end

  end
