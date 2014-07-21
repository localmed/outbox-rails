require 'action_mailer'

module Outbox
  class Notifier < ActionMailer::Base
    extend Outbox::DefineInheritableMethod
    include Outbox::NotifierTypes

    abstract!

    alias_method :_render_email, :mail
    undef :mail

    class << self
      alias_method :defaults, :default

      # Returns the name of current notifier. This method is also being used
      # as a path for a view lookup. If this is an anonymous notifier,
      # this method will return +anonymous+ instead.
      def notifier_name(value = nil)
        if value.nil?
          mailer_name
        else
          self.mailer_name = value
        end
      end
      alias_method :notifier_name=, :notifier_name

      protected

      def method_missing(method_name, *args) # :nodoc:
        if respond_to?(method_name)
          new(method_name, *args).message
        else
          super
        end
      end
    end

    def initialize(method_name = nil, *args) # :nodoc:
      super()
      # Make sure we don't ever get a NullMail object.
      @_mail_was_called = true
      @_message_rendered = false
      @_message = build_message
      process(method_name, *args) if method_name
    end

    # The composed Outbox::Message instance.
    def message
      render_message unless message_rendered?
      @_message
    end

    # Returns true if the message has already been rendered.
    def message_rendered?
      @_message_rendered
    end

    # Renders the message body. This is analagous to ActionMailer's #mail
    # method, but is not required - it will be called implicitly when the
    # #message object is retrieved.
    def render_message(options = {}, &block)
      @_message_rendered = true
      if @_message.email
        email = @_message.email
        skip_email = false
      else
        email = Outbox::Messages::Email.new
        skip_email = true
      end

      # Render an email using the #mail interface so we don't have
      # to rewrite the template logic. Even if we aren't sending an email
      # we can still use the rendered templates in other messages types.
      begin
        render_email(email, options, &block)
      rescue ActionView::MissingTemplate => error
        raise error unless skip_email
      end

      @_message.assign_message_type_values(options)
      assign_body_from_email(email)
      @_message
    end

    def headers(args = nil) # :nodoc:
      # Make sure the email message instance exists
      email({}) if email.nil?
      if args
        email.headers(args)
      else
        email
      end
    end

    def attachments
      # Make sure the email message instance exists
      email({}) if email.nil?
      email.attachments
    end

    protected

    def build_message
      message = Outbox::Message.new(self.class.default_params.dup)
      Outbox::Message.message_types.each_key do |message_type|
        message.public_send(message_type, {})
      end
      message
    end

    def assign_body_from_email(email)
      text_part = email.parts.find { |p| p.mime_type == 'text/plain' }
      if text_part
        @_message.each_message_type do |message_type, message|
          next if message.nil? || message_type == :email
          message.body = text_part.body.raw_source
        end
      end
    end

    def render_email(email, options, &block)
      email_options = options.extract!(
        :content_type, :charset, :parts_order,
        :body, :template_name, :template_path
      )
      email_options.merge!(options.delete(:email)) if options[:email]
      # ActionMailer will use the default i18n subject
      # unless we explicitly set it on this options hash.
      email_options[:subject] ||= email.subject if email.subject

      outbox_message = @_message
      @_message = email
      _render_email(email_options, &block)
    ensure
      @_message = outbox_message
      email
    end

    ActiveSupport.run_load_hooks(:outbox_notifier, self)
  end
end
