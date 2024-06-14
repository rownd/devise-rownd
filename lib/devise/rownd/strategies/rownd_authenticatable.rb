require 'devise'
require 'devise/strategies/authenticatable'
require 'devise/rownd/user'
require 'devise/rownd/token'
require 'devise/rownd/log'

require_relative '../../../../config/initializers/app_creds'


# jose prefers to use libsodium for EdDSA to work. This next line tells jose to fallback to the ruby
# crypto library in the event that libsodium is not installed
JOSE.crypto_fallback = '1'

module Devise
  module Strategies
    include Devise::Rownd::Token

    class RowndAuthenticatable < Authenticatable
      def valid?
        valid_for_auth = params[:access_token].present?
        Devise::Rownd::Log.debug("valid for authentication?: #{valid_for_auth}")
        valid_for_auth
      end

      # All Strategies must define this method.
      def authenticate!
        Devise::Rownd::Log.debug('authenticate!')
        access_token = params[:access_token]

        Devise::Rownd::Log.error('authenticate! could not proceed. no access token') unless access_token
        return fail!('No Access Token') unless access_token

        begin
          decoded_jwt = ::Devise::Rownd::Token.verify_token(access_token)

          @app_id = decoded_jwt['aud'].find(/^app:.+/).first.split(':').last

          configured_app_id = Devise::Rownd.app_id
          ok = @app_id == configured_app_id
          unless ok
            Devise::Rownd::Log.error('authenticate! failed: JWT not authorized for app')
            return fail!('JWT not authorized for app')
          end

          user_data = Devise::Rownd::User.fetch_user(access_token)
          unless user_data
            Devise::Rownd::Log.error('authenticate! failed: Failed to fetch user')
            fail!('Failed to fetch user')
          end

          rownd_user = Devise::Rownd::User.new(user_data, access_token)

          unless rownd_user
            Devise::Rownd::Log.error('authenticate! failed: failed to initialize user')
            return fail!('Failed to initialize user')
          end

          success!(rownd_user)
        rescue StandardError => e
          Devise::Rownd::Log.error("authenticate! failed #{e.message}")
          fail!("Unable to authenticate: #{e.message}")
        end
      end

      def return_to_after_sign_out
        '/'
      end
    end
  end
end

Warden::Strategies.add(:rownd_authenticatable, Devise::Strategies::RowndAuthenticatable)
Devise.add_module :rownd_authenticatable, :strategy => true
