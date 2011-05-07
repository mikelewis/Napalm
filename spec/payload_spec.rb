require File.dirname(__FILE__) + '/spec_helper'

describe Napalm::Payload do
  it "should be able to create a payload with optional data" do
    Napalm::Payload.new(:this_cmd).data.should eq(nil)
  end
end

