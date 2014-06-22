class BaseNotifier < Outbox::Notifier
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

  def custom_headers
    headers 'X-Custom-1' => 'foo'
    headers['X-Custom-2'] = 'bar'
  end
end
