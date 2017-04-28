require 'rails'

module Outbox
  module Rails
    class Railtie < ::Rails::Railtie
      config.outbox = ActiveSupport::OrderedOptions.new

      initializer 'outbox.logger' do
        ActiveSupport.on_load(:outbox_notifier) do
          self.logger ||= ::Rails.logger
        end
      end

      initializer 'outbox.config' do |app|
        options = app.config.outbox

        ActiveSupport.on_load(:outbox) do
          Outbox::Message.use_test_client if options.delete(:use_test_client)

          options.each do |key, value|
            option_setter = "#{key}="
            if Outbox::Message.respond_to?(option_setter)
              Outbox::Message.public_send(option_setter, value)
            end
          end
        end
      end
    end
  end
end
