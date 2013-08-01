require 'rails'

module Outbox
  module Rails
    class Railtie < ::Rails::Railtie
      config.outbox = Outbox::Message

      initializer 'outbox.logger' do
        ActiveSupport.on_load(:outbox) { self.logger ||= ::Rails.logger }
      end
    end
  end
end
