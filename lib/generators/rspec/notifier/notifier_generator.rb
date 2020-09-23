# frozen_string_literal: true

module Rspec
  module Generators
    class NotifierGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :actions, type: :array, default: [], banner: 'method method'

      def generate_mailer_spec
        template 'notifier_spec.rb', File.join('spec/notifiers', class_path, "#{file_name}_spec.rb")
      end

      # def generate_fixtures_files
      #   actions.each do |action|
      #     @action, @path = action, File.join(file_path, action)
      #     template 'fixture', File.join('spec/fixtures', @path)
      #   end
      # end
    end
  end
end
