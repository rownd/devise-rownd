module Devise
  module Rownd
    class User
      attr_reader :data, :is_verified_user

      def initialize(data)
        @data = data
        Devise::Rownd.app_schema.each do |key, _value|
          self.class.send :attr_accessor, key
          instance_variable_value = data.is_a?(Hash) && data.key?(key) ? data[key] : nil
          instance_variable_set("@#{key}", instance_variable_value)
        end
        @is_verified_user = data.key?('is_verified_user') ? data['is_verified_user'] : false
      end

      def verified?
        @is_verified_user
      end
    end
  end
end
