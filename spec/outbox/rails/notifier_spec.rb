require 'spec_helper'

describe Outbox::Notifier do
  describe 'calling actions' do
    it 'does not raise error' do
      expect{BaseNotifier.welcome}.not_to raise_error()
    end

    it 'returns an Outbox Message' do
      message = BaseNotifier.welcome
      expect(message).to be_an_instance_of(Outbox::Message)
    end

    it 'passes the args to the action' do
      message = BaseNotifier.welcome email: { subject: 'Subject Line' }
      expect(message.email.subject).to eq('Subject Line')
    end
  end

  describe '.logger' do
    it 'defaults to Rails.logger' do
      expect(BaseNotifier.logger).to be(Rails.logger)
    end
  end

  describe '.defaults' do
    it 'sets the default values' do
      message = BaseNotifier.welcome
      expect(message.email.from).to eq(['noreply@myapp.com'])
    end
  end

  describe '.notifier_name' do
    it 'returns the underscored class name' do
      expect(BaseNotifier.notifier_name).to eq('base_notifier')
    end

    it 'returns anonymous for anonymous classes' do
      notifier = Class.new Outbox::Notifier
      expect(notifier.notifier_name).to eq('anonymous')
    end

    it 'is configurable' do
      notifier = Class.new Outbox::Notifier
      notifier.notifier_name 'some_notifier'
      expect(notifier.notifier_name).to eq('some_notifier')
      notifier.notifier_name = 'another_notifier'
      expect(notifier.notifier_name).to eq('another_notifier')
    end
  end

  describe '#email' do
    it 'composes an email using Outbox interface' do
      message = BaseNotifier.composed_message_with_implicit_render
      expect(message.email.from).to eq(['noreply@myapp.com'])
      expect(message.email.subject).to eq('Composed Message')
    end
  end

  describe '#message' do
    it 'renders the template' do
      message = BaseNotifier.welcome
      expect(message.email.body.encoded.strip).to eq('Welcome')
    end

    it 'handles multipart templates' do
      message = BaseNotifier.implicit_multipart
      expect(message.email.parts.size).to eq(2)
      part_1 = message.email.parts[0]
      part_2 = message.email.parts[1]
      expect(part_1.mime_type).to eq('text/plain')
      expect(part_1.body.encoded.strip).to eq('TEXT Implicit Multipart')
      expect(part_2.mime_type).to eq('text/html')
      expect(part_2.body.encoded.strip).to eq('HTML Implicit Multipart')
    end
  end
end
