# frozen_string_literal: true

class CustomizedNotifier < Outbox::Notifier
  defaults email: { from: 'noreply@myapp.com' }, sms: { from: '+12255551234' }

  def with_defaults; end
end
