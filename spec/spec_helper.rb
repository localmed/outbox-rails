$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'combustion'

Combustion.initialize!(:all) do
  config.outbox.use_test_client = true
  config.outbox.default_email_client_settings = { option_1: true }
end

require 'rspec-rails'
require 'outbox/rails'
