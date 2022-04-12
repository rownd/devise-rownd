require 'devise'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class RowndAuthenticatable < Authenticatable
      def valid?
        session_present = session[:rownd_user].present?
        session_present
      end

      # All Strategies must define this method.
      def authenticate!
        user = session[:rownd_user]

        fail(:unable_to_authenticate) unless user

        success!(user)
      end
    end
  end
end

Warden::Strategies.add(:rownd_authenticatable, Devise::Strategies::RowndAuthenticatable)
