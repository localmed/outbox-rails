# frozen_string_literal: true

require 'spec_helper'

describe Outbox::Rails do
  it 'has a version number' do
    expect(Outbox::Rails::VERSION).to_not be_nil
  end
end
