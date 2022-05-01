require 'devise'
require 'devise/strategies/authenticatable'
require 'devise/rownd/user'
require 'devise/rownd/api'
require 'jose'

require_relative '../../../../config/initializers/app_creds'

module Devise
  module Strategies
    include ::Devise::Rownd::API

    class RowndAuthenticatable < Authenticatable
      def valid?
        session[:rownd_user_access_token].present?
      end

      # All Strategies must define this method.
      def authenticate!
        @access_token = session[:rownd_user_access_token]
        return fail!('No Access Token') unless @access_token

        @decoded_jwt = verify_token(@access_token)
        @app_id = @decoded_jwt['aud'].find(/^app:.+/).first.split(':').last

        configured_app_id = Devise::Rownd.app_id
        ok = @app_id == configured_app_id
        return fail!('JWT not authorized for app') unless ok

        rownd_user = Devise::Rownd::User.new(fetch_user)

        return fail!(:unable_to_authenticate) unless rownd_user

        success!(rownd_user)
      end

      def return_to_after_sign_out
        '/'
      end

      def fetch_user
        cache_key = "rownd_user_#{@decoded_jwt['jti']}"
        if session[:rownd_stale_data] == true
          data = fetch_user_from_api
          Rails.cache.write(cache_key, data, expires_in: 1.minute)
          session.delete(:rownd_stale_data) if session[:rownd_stale_data]
          return data
        end

        Rails.cache.fetch(cache_key, expires_in: 1.minute) do
          fetch_user_from_api
        end
      end

      def fetch_user_from_api
        response = ::Devise::Rownd::API.make_api_call(
          "/me/applications/#{@app_id}/data",
          {
            method: 'GET',
            headers: { 'Authorization' => "Bearer #{@access_token}" }
          }
        )
        return response.body['data'] if response.success?

        raise StandardError, response.body['message']
      end

      def verify_token(access_token)
        for jwk in jwks
          begin
            response = JOSE::JWT.verify_strict(jwk, ['EdDSA'], access_token)
            return response[1].fields if response[0]
          rescue StandardError => e
            puts "Error: #{e}"
            next
          end
          raise StandardError
        end
      end

      def jwks
        Rails.cache.fetch('rownd_jwks', expires_in: 15.minutes) do
          fetch_jwks
        end
      end

      def fetch_jwks
        response = ::Devise::Rownd::API.make_api_call('/hub/auth/keys')
        response.body['keys']
      end
    end
  end
end

Warden::Strategies.add(:rownd_authenticatable, Devise::Strategies::RowndAuthenticatable)
Devise.add_module :rownd_authenticatable, :strategy => true
