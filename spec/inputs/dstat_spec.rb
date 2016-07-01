# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/dstat"

describe LogStash::Inputs::Dstat do

  it_behaves_like "an interruptible input plugin" do
    let(:config) { { "interval" => 100 } }
  end

end
