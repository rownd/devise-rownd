require 'devise'
require 'devise/strategies/authenticatable'
require 'devise/rownd/user'

module Devise
  module Strategies
    class RowndAuthenticatable < Authenticatable
      def valid?
        session[:rownd_user_data].present?
      end

      # All Strategies must define this method.
      def authenticate!
        session_data = session[:rownd_user_data]
        user = Devise::Rownd::User.new(session_data)

        fail(:unable_to_authenticate) unless user

        success!(user)
      end
    end
  end
end

Warden::Strategies.add(:rownd_authenticatable, Devise::Strategies::RowndAuthenticatable)
Devise.add_module :rownd_authenticatable, :strategy => true
