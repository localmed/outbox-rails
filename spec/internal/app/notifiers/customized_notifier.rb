class CustomizedNotifier < Outbox::Notifier
  defaults email: { from: 'noreply@myapp.com' }

  def with_defaults
  end
end
