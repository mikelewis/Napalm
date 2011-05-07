require File.dirname(__FILE__) + '/spec_helper'

describe Napalm::Worker do

  it "should include EM::P::ObjectProtocol" do
    Napalm::Worker.include?(EM::P::ObjectProtocol)
  end

  it "should respond to receive object" do
    Napalm::Worker.instance_methods.include?(:receive_object).should eq(true)
  end

  it "should respond to private method do_job" do
    Napalm::Worker.private_instance_methods.include?(:do_job).should eq(true)
  end

  it "should respond to private method competed_job" do
    Napalm::Worker.private_instance_methods.include?(:completed_job).should eq(true)
  end

  it "should respond to class method worker_methods" do
    Napalm::Worker.respond_to?(:worker_methods).should eq(true)
  end

  context "worker methods" do

    after do
      Napalm::Worker.instance_variable_set(:@worker_meths, [])
    end
    it "should add worker methods" do
      Napalm::Worker.worker_methods :this, :and, :that
      Napalm::Worker.worker_meths.should eq([:this, :and, :that])
    end

    it "should add workers methods in multiple calls" do
      Napalm::Worker.worker_methods :this, :and, :that
      Napalm::Worker.worker_methods :one_more
      Napalm::Worker.worker_meths.should eq([:this, :and, :that, :one_more])
    end
  end
end

