require 'spec_helper'

describe Outbox::Rails::Railtie do
  describe '.logger' do
    it 'defaults to Rails.logger' do
      expect(BaseNotifier.logger).to be(Rails.logger)
    end
  end

  describe '.config' do
    it 'sets configuration' do
      email_client = Outbox::Messages::Email.default_client
      expect(email_client).to be_a(Outbox::Clients::TestClient)
      expect(email_client.settings[:option_1]).to eq(true)
    end
  end
end
