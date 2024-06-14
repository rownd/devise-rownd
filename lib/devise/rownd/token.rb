require 'devise/rownd/api'
require 'devise/rownd/caching'
require 'devise/rownd/log'
require 'jose'

# jose prefers to use libsodium for EdDSA to work. This next line tells jose to fallback to the ruby
# crypto library in the event that libsodium is not installed
JOSE.crypto_fallback = '1'

module Devise::Rownd
  module Token
    def verify_token(access_token)
      raise StandardError, 'No JWKs' unless jwks

      jwks.each do |jwk|
        response = JOSE::JWT.verify_strict(jwk, ['EdDSA'], access_token)
        return response[1].fields if response[0]
      rescue StandardError => e
        Devise::Rownd::Log.debug("jwt not validated: #{e.message}")
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

      Devise::Rownd::Log.error("Failed to fetch JWKs: #{response.body['message']}")
      nil
    end

    module_function :jwks, :fetch_jwks_from_api, :verify_token
  end
end
