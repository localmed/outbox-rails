# frozen_string_literal: true

require 'action_mailer'

module Outbox
  class Notifier < ActionMailer::Base
    extend Outbox::DefineInheritableMethod
    include Outbox::NotifierTypes

    abstract!

    alias _render_email mail
    undef :mail

    class << self
      alias defaults default

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
      alias notifier_name= notifier_name

      protected

      # rubocop:disable Style/MissingRespondToMissing
      def method_missing(method_name, *args) # :nodoc:
        if respond_to?(method_name)
          new(method_name, *args).message
        else
          super
        end
      end
      # rubocop:enable Style/MissingRespondToMissing
    end

    def initialize(method_name = nil, *args) # :nodoc:
      super()
      @_message_rendered = false
      @_message = build_message
      process(method_name, *args) if method_name
    end

    def process(*args) # :nodoc:
      original_message = @_message
      super
      # Make sure we don't ever get a NullMail object.
      @_message = original_message
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
      render_email(@_message.email, options, &block) if @_message.email
      render_message_types(options)
      @_message.assign_message_type_values(options)
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

    def details_for_lookup
      { variants: [:email] }
    end

    def build_message
      message = Outbox::Message.new(self.class.default_params.dup)
      Outbox::Message.message_types.each_key do |message_type|
        message.public_send(message_type, {})
      end
      message
    end

    def render_email(email, options, &block)
      email_options_keys = %i[content_type charset parts_order body template_name template_path]
      email_options = options.select { |key, _| email_options_keys.include? key }
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

    def render_message_types(options)
      templates = find_message_type_templates(options)
      templates.each do |template|
        variants = template_variants(template)
        if variants.empty?
          assign_body(render(template: template))
        else
          assign_body(render(template: template, variants: variants), variants)
        end
      end
    end

    def find_message_type_templates(options)
      template_path = options[:template_path] || self.class.mailer_name
      template_name = options[:template_name] || action_name
      lookup_context.find_all(
        template_name, Array(template_path), false, [],
        formats: [:text],
        variants: message_types_without_email
      )
    end

    def assign_body(body, only_message_types = nil)
      only_message_types =
        if only_message_types
          only_message_types.map(&:to_sym)
        else
          message_types_without_email
        end
      @_message.each_message_type do |message_type, message|
        message.body = body if message && message.body.nil? && message_type.in?(only_message_types)
      end
    end

    def apply_defaults(headers)
      headers_with_defaults = super(headers)
      message_types.each do |message_type|
        headers_with_defaults.delete(message_type)
      end
      headers_with_defaults
    end

    def message_types
      Outbox::Message.message_types.keys
    end

    def message_types_without_email
      message_types - [:email]
    end

    def template_variants(template)
      if template.respond_to?(:variant)
        [template.variant].compact
      elsif template.respond_to?(:variants)
        template.variants.compact
      else
        []
      end
    end

    ActiveSupport.run_load_hooks(:outbox_notifier, self)
  end
end
