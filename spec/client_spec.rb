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

=begin
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
        callback_result = nil
        r = Napalm::Client.do_async(:add_me, 20, 20) do |result|
          callback_result = result
        end
        sleep 4 #emulate work
        callback_result.should eq(40)
      end

      it "should be able receive initial response when adding a callback" do
        call = Napalm::Client.do_async(:add_me, 20, 20) do |result|
          result
        end
        sleep 4
        call.should eq(Napalm::Codes::OK)

      end

      it "should be able to run other tasks while waiting for callback" do
        responses = []
        Napalm::Client.do_async(:long_running_1, "Mike", 5) do |result|
          # should return mike
          responses << result
        end
        Napalm::Client.do(:long_running_1, "Tim", 10).should eq("Tim")
        responses.should eq(["Mike"])
      end

      it "should be able to run multiple async callbacks at once" do
        responses = []
        Napalm::Client.do_async(:long_running_1, "First", 5) do |result|
          responses << result
        end
        Napalm::Client.do_async(:long_running_1, "Second", 5) do |result|
          responses << result
        end
        Napalm::Client.do_async(:long_running_1, "Third", 5) do |result|
          responses << result
        end
        sleep 6 #do work
        responses.should eq(["First","Second", "Third"])
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

=end
      context "Bulk Calls" do
        before(:all) do
          #@workers = 16.times.map{ launch_worker("basic_worker")}
          @worker1_pid = launch_worker("basic_worker")
        end

        after(:all) do
          #@workers.each{|x| Process.kill("HUP", x)}
          Process.kill("HUP", @worker1_pid)
        end

        it "should beable to run bulk calls with async calls" do
          results = []
          Napalm::Client.start do |client|
            3.times do |n|
              client.do_async(:add_me, 1, n) {|result| results << result}
            end
          end
          results.should eq([1,2,3])
        end

        #it "should be able to run bulk calls with sync calls" do
        #  Napalm::Client.start do |client|
        #    client.do(:add_me, 1, 3).should eq(4)
        #  end
       # end
      end
  end
