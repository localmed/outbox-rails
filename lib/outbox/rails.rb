require 'outbox'
require 'outbox/rails/version'
require 'outbox/rails/railtie'
require 'active_support/rails'

module Outbox
  autoload :Notifier, 'outbox/notifier'

  module Rails
  end

  ActiveSupport.run_load_hooks(:outbox, self)
end
