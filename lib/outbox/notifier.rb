require 'action_mailer'

module Outbox
  class Notifier < ActionMailer::Base
    abstract!

    alias_method :_render_email, :mail
    undef :mail

    class << self
      alias :defaults :default

      # Returns the name of current notifier. This method is also being used
      # as a path for a view lookup. If this is an anonymous notifier,
      # this method will return +anonymous+ instead.
      def notifier_name(value = nil)
        if value.nil?
          self.mailer_name
        else
          self.mailer_name = value
        end
      end
      alias :notifier_name= :notifier_name

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
      @_message = Outbox::Message.new self.class.default_params.dup
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
      @_message.email ||= Outbox::Messages::Email.new

      # Render an email using the #mail interface so we don't have
      # to rewrite the template logic. Even if we aren't sending an email
      # we can still use the rendered templates in other messages types.
      email_options = options.extract! :content_type, :charset, :parts_order,
                                       :body, :template_name, :template_path
      email_options.merge!(options.delete(:email)) if options[:email]
      email_options[:subject] ||= email.subject if email.subject
      email = render_email(email_options, &block)

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

    def assign_body_from_email(email)
      # TODO: Implement this later once we have multiple message types. This
      # will extract the rendered body from the mail (preferring text/plain)
      # and assign it to the other message types.
    end

    def render_email(options, &block)
      outbox_message = @_message
      @_message = outbox_message.email
      email = _render_email(options, &block)
      @_message = outbox_message
      email
    end

    def method_missing(method, *args, &block)
      if @_message.respond_to?(method)
        @_message.public_send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      super || @_message.respond_to?(method, include_private)
    end

    ActiveSupport.run_load_hooks(:outbox_notifier, self)
  end
end
