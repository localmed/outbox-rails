module Outbox
  module Generators
    class NotifierGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      argument :actions, type: :array, default: [], banner: 'method method'
      check_class_collision

      def create_notifier_file
        template 'notifier.rb', File.join('app/notifiers', class_path, "#{file_name}.rb")
      end

      hook_for :template_engine, :test_framework
    end
  end
end
