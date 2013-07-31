# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'outbox/rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'outbox-rails'
  spec.version       = Outbox::Rails::VERSION
  spec.authors       = ['Pete Browne']
  spec.email         = ['pete.browne@localmed.com']
  spec.description   = %q{Rails Engine for sending email, SMS, and push notifications.}
  spec.summary       = %q{Rails Engine for sending email, SMS, and push notifications.}
  spec.homepage      = 'https://github.com/localmed/outbox'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'outbox', '~> 0.1.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
