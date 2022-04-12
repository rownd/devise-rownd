module Devise
  module Rownd
    class User
      attr_reader :data

      def initialize(data)
        @data = data
        Devise::Rownd.app_schema.each do |key, value|
          self.class.send :attr_accessor, key
          instance_variable_set("@#{key}", data[key])
        end
      end

      def admin?
        return true if data['role'] == 'admin'
      end
    end
  end
end
