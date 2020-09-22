# frozen_string_literal: true

require 'spec_helper'

describe Outbox::Notifier do
  describe 'calling actions' do
    it 'does not raise error' do
      expect { BaseNotifier.welcome }.not_to raise_error
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

  describe '.defaults' do
    it 'sets the default values', focus: true do
      message = CustomizedNotifier.with_defaults
      expect(message.email.from).to eq(['noreply@myapp.com'])
      expect(message.sms.from).to eq('+12255551234')
      expect(message.email['email']).to be_nil
      expect(message.email['sms']).to be_nil
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
      part1 = message.email.parts[0]
      part2 = message.email.parts[1]
      expect(part1.mime_type).to eq('text/plain')
      expect(part1.body.encoded.strip).to eq('TEXT Implicit Multipart')
      expect(part2.mime_type).to eq('text/html')
      expect(part2.body.encoded.strip).to eq('HTML Implicit Multipart')
    end

    it 'handles attachments' do
      message = BaseNotifier.implicit_multipart(attachments: true)
      attachment = message.email.attachments.first
      expect(attachment.mime_type).to eq('application/pdf')
      expect(attachment.decoded.strip).to eq('This is test File content')
    end

    it 'handles custom headers' do
      message = BaseNotifier.custom_headers
      expect(message.email.header['X-Custom-1'].value).to eql('foo')
      expect(message.email.header['X-Custom-2'].value).to eql('bar')
    end

    it 'handles implicit SMS templates' do
      message = BaseNotifier.implicit_multipart
      expect(message.sms.body.strip).to eq('TEXT Implicit Multipart')
    end

    it 'handles explicit SMS messages' do
      message = BaseNotifier.explicit_sms_message(true)
      expect(message.email).to be_nil
      expect(message.sms.from).to eq('1234')
      expect(message.sms.body).to eq('Explicit Message')
    end

    it 'raises template errors when sending emails' do
      expect do
        BaseNotifier.explicit_sms_message
      end.to raise_error(ActionView::MissingTemplate)
    end

    it 'supports implicit variants by message type' do
      message = BaseNotifier.implicit_variants
      expect(message.email.body.encoded.strip).to eql('Email Variant')
      expect(message.sms.body.strip).to eql('SMS Variant')
    end

    it 'supports layout variants' do
      message = BaseNotifier.implicit_variants('notification')
      expect(message.email.body.encoded.strip).to eql('Email Layout: Email Variant')
      expect(message.sms.body.strip).to eql('SMS Layout: SMS Variant')
    end

    it 'only renders the SMS template once' do
      notifier = BaseNotifier.new(:only_sms_template)
      expect(notifier).to receive(:render).once.and_return('Only SMS')
      message = notifier.message
      expect(message.email).to_not be_present
      expect(message.sms.body).to eql('Only SMS')
    end
  end
end
