require File.dirname(__FILE__) + '/spec_helper'

describe Napalm::Worker do

  it "should include EM::P::ObjectProtocol" do
    Napalm::Worker.include?(EM::P::ObjectProtocol)
  end
end

