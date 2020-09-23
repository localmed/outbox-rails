# frozen_string_literal: true

class BaseNotifier < Outbox::Notifier
  layout :set_layout

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

  def explicit_sms_message(skip_email = false)
    skip_email! if skip_email
    sms do
      from '1234'
      body 'Explicit Message'
    end
  end

  def implicit_variants(layout = false)
    @layout = layout
  end

  def only_sms_template
    skip_email!
  end

  protected

  def set_layout
    @layout
  end
end
