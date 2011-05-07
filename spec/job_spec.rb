require File.dirname(__FILE__) + '/spec_helper'

describe Napalm::Job do
  before do
    @job = Napalm::Job.new(:test_meth, [:arg1, :arg2])
  end
  it "should give quick stats" do
    @job.quick_stats.should eq(
      {
        :meth => :test_meth,
        :args => [:arg1, :arg2],
        :sync => @job.sync,
        :id => @job.id,
        :time => @job.instance_variable_get(:@time)
      }
    )
  end
  
  it "should unmarshal args" do
    @job.instance_variable_set(:@args, Marshal.dump([1,2]))
    @job.unmarshal_args!
    @job.args.should eq([1,2])
  end

  it "should not be able to unmarshal unknown types" do
    class Person
      def initialize
        @age = 20
      end
    end
    @job.instance_variable_set(:@args, Marshal.dump(Person.new))
    Object.instance_eval {remove_const(:Person)}
    @job.unmarshal_args!.should eq(Napalm::Codes::INVALID_WORKER_ARGUMENTS)
  end

  it "should be able to set result and return self" do
    @job.set_result!("Result").should eq(@job)
  end

  it "should be able to set client and return self" do
    @job.set_client!("127.0.01", 54321).should eq(@job)
  end

  it "should be able to set client" do
    @job.set_client!("127.0.0.1", 54321)
    @job.client.should eq({:ip=>"127.0.0.1", :port=>54321})
  end

  it "should include Napalm::Utils" do
    Napalm::Job.include?(Napalm::Utils).should eq(true)
  end
end
