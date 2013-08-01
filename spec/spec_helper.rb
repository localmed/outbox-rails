$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'combustion'

Combustion.initialize!

require 'rspec-rails'
require 'outbox/rails'
