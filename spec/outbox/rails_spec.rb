require 'spec_helper'

describe Outbox::Rails do
  it 'has a version number' do
    Outbox::Rails::VERSION.should_not be_nil
  end
end
