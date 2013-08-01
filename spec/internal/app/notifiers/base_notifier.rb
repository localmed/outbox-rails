class BaseNotifier < Outbox::Notifier
  defaults email: { from: 'noreply@myapp.com' }

  def welcome(hash = {})
    render_message(hash)
  end

  def implicit_multipart(hash = {})
    attachments['invoice.pdf'] = 'This is test File content' if hash.delete(:attachments)
    render_message(hash)
  end

  def composed_message_with_implicit_render
    email do
      subject 'Composed Message'
    end
  end
end
