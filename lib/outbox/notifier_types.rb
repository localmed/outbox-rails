# frozen_string_literal: true

module Outbox
  module NotifierTypes
    extend ActiveSupport::Concern

    included do
      Outbox::Message.message_types.each_key do |message_type|
        define_notifier_type_reader(message_type)
        define_notifier_type_writer(message_type)
        define_skip_notifier_type(message_type)
      end
    end

    module ClassMethods
      DYNAMIC_MODULE_NAME = :DynamicNotifierTypes

      protected

      def define_notifier_type_reader(name)
        define_inheritable_method(DYNAMIC_MODULE_NAME, name) do |*args, &block|
          @_message.public_send(name, *args, &block)
        end
      end

      def define_notifier_type_writer(name)
        define_inheritable_method(DYNAMIC_MODULE_NAME, "#{name}=") do |value|
          @_message.public_send("#{name}=", value)
        end
      end

      def define_skip_notifier_type(name)
        define_inheritable_method(DYNAMIC_MODULE_NAME, "skip_#{name}!") do
          @_message.public_send("#{name}=", nil)
        end
      end
    end
  end
end
