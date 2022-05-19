require 'devise'
require 'devise/strategies/authenticatable'
require 'devise/rownd/user'
require 'devise/rownd/api'
require 'devise/rownd/caching'
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

        begin
          @decoded_jwt = verify_token(@access_token)

          @app_id = @decoded_jwt['aud'].find(/^app:.+/).first.split(':').last

          configured_app_id = Devise::Rownd.app_id
          ok = @app_id == configured_app_id
          return fail!('JWT not authorized for app') unless ok

          user_data = fetch_user
          return fail!('Failed to fetch user') unless user_data

          rownd_user = Devise::Rownd::User.new(user_data)

          return fail!('Failed to initialize user') unless rownd_user

          success!(rownd_user)
        rescue StandardError => e
          fail!("Unable to authenticate: #{e.message}")
        end
      end

      def return_to_after_sign_out
        '/'
      end

      def fetch_user
        cache_key = "rownd_user_#{@decoded_jwt['jti']}"
        if session[:rownd_stale_data] == true
          data = fetch_user_from_api
          return nil unless data

          Rails.cache.write(cache_key, data, expires_in: 1.minute)
          session.delete(:rownd_stale_data) if session[:rownd_stale_data]
          return data
        end

        Devise::Rownd::Caching.fetch(cache_key, 1.minute) { fetch_user_from_api }
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

        Rails.logger.error("Failed to fetch user: #{response.body['message']}")
        nil
      end

      def verify_token(access_token)
        raise StandardError, 'No JWKs' unless jwks

        jwks.each do |jwk|
          response = JOSE::JWT.verify_strict(jwk, ['EdDSA'], access_token)
          return response[1].fields if response[0]
        rescue StandardError
          next
        end
        raise StandardError, 'Failed to verify JWT. No matching JWKs'
      end

      def jwks
        Devise::Rownd::Caching.fetch('rownd_jwks', 15.minutes) { fetch_jwks_from_api }
      end

      def fetch_jwks_from_api
        response = ::Devise::Rownd::API.make_api_call('/hub/auth/keys')
        return response.body['keys'] if response.success?

        Rails.logger.error("Failed to fetch JWKs: #{response.body['message']}")
        nil
      end
    end
  end
end

Warden::Strategies.add(:rownd_authenticatable, Devise::Strategies::RowndAuthenticatable)
Devise.add_module :rownd_authenticatable, :strategy => true
