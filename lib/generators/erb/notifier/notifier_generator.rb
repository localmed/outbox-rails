require 'rails/generators/erb/controller/controller_generator'

module Erb # :nodoc:
  module Generators # :nodoc:
    class NotifierGenerator < ControllerGenerator # :nodoc:
      source_root File.expand_path('../templates', __FILE__)

      protected

      def format
        :text
      end
    end
  end
end
