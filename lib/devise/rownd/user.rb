require 'devise/rownd/api'
require 'devise/rownd/caching'
require 'devise/rownd/token'
require 'devise/rownd/log'

module Devise
  module Rownd
    extend ActiveSupport::Concern

    class User
      attr_reader :user_id, :auth_level, :data, :is_verified_user, :access_token

      def initialize(profile, access_token)
        Devise::Rownd::Log.debug("initialize user: #{profile} - #{access_token}")
        @user_id = profile['data']['user_id']
        @data = profile
        Devise::Rownd.app_schema.each do |key, _value|
          self.class.send :attr_accessor, key
          instance_variable_value = profile['data'].is_a?(Hash) && profile['data'].key?(key) ? profile['data'][key] : nil
          instance_variable_set("@#{key}", instance_variable_value)
        end

        @access_token = access_token
        @auth_level = profile['auth_level']
        @is_verified_user = profile['auth_level'] == 'verified'

        Devise::Rownd::Log.debug('successfully initialized user')
      end

      def verified?
        @is_verified_user
      end

      def self.fetch_user(access_token, bypass_cache = false)
        Devise::Rownd::Log.debug("fetch_user: #{self}")
        begin
          decoded_jwt = ::Devise::Rownd::Token.verify_token(access_token)
          app_id = decoded_jwt['aud'].find(/^app:.+/).first.split(':').last

          cache_key = "rownd_user_#{decoded_jwt['https://auth.rownd.io/app_user_id']}"
          if bypass_cache == true
            Devise::Rownd::Log.debug('fetch_user bypassing cache')
            profile = fetch_user_from_api(access_token, app_id)
            return nil unless profile

            Rails.cache.write(cache_key, profile, expires_in: 1.minute)
            return profile
          end

          Devise::Rownd::Log.debug('fetch_user from cache if possible')
          Devise::Rownd::Caching.fetch(cache_key, 1.minute) { fetch_user_from_api(access_token, app_id) }
        rescue StandardError => e
          Devise::Rownd::Log.error("fetch_user failed: #{e.message}")
          nil
        end
      end

      def self.fetch_user_from_api(access_token, app_id)
        response = ::Devise::Rownd::API.make_api_call(
          "/me/applications/#{app_id}/data",
          {
            method: 'GET',
            headers: { 'Authorization' => "Bearer #{access_token}" }
          }
        )
        return response.body if response.success?

        Devise::Rownd::Log.error("Failed to fetch user: #{response.body}")
        nil
      end
    end
  end
end
