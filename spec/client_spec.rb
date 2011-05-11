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

  context "Client interacting with basic worker" do
    before(:all) do
      @worker1_pid = launch_worker("basic_worker")
    end

    after(:all) do
      Process.kill("HUP", @worker1_pid)
    end
    
    it "should return a value with a sync call" do
      Napalm::Client.do(:add_me, 5, 100).should eq(105)
    end
    it "should not beable to call a worker method that does not exist for sync" do
      Napalm::Client.do(:some_function, [1,2]).should eq(Napalm::Codes::NO_AVAILABLE_WORKERS)
    end

    it "should beable to run bulk calls with async calls" do
      results = []
      Napalm::Client.start do |client|
        3.times do |n|
          client.do_async(:add_me, 1, n) {|result| results << result}
        end
      end
      results.inject(&:*).should eq(6)
    end

    it "should be able to return error codes" do
      Napalm::Client.start do |client|
        client.do_async(:random_method, 1, 2, "blah"){|result| result.should eq(Napalm::Codes::NO_AVAILABLE_WORKERS)}
      end
    end

    it "should be able to call async without block" do
      Napalm::Client.start do |client|
        client.do_async(:save_file, "mike_file_name")
      end
      File.exists?("mike_file_name").should eq(true)
      File.delete("mike_file_name")
    end
  end
end
