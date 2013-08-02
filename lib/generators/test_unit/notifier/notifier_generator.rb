module TestUnit
  module Generators
    class NotifierGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      check_class_collision suffix: 'Test'

      argument :actions, type: :array, default: [], banner: 'method method'

      def generate_mailer_spec
        template 'notifier_test.rb', File.join('test/notifiers', class_path, "#{file_name}_test.rb")
      end
    end
  end
end
