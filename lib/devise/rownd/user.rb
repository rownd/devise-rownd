require 'devise/rownd/api'
require 'devise/rownd/caching'
require 'devise/rownd/token'
require 'devise/rownd/log'

module Devise
  module Rownd
    extend ActiveSupport::Concern

    class User
      attr_reader :user_id, :data, :is_verified_user, :access_token

      def initialize(data, access_token)
        Devise::Rownd::Log.debug("initialize user: #{data} - #{access_token}")
        @user_id = data['user_id']
        @data = data
        @access_token = access_token
        Devise::Rownd.app_schema.each do |key, _value|
          self.class.send :attr_accessor, key
          instance_variable_value = data.is_a?(Hash) && data.key?(key) ? data[key] : nil
          instance_variable_set("@#{key}", instance_variable_value)
        end

        decoded_jwt = ::Devise::Rownd::Token.verify_token(access_token)
        is_verified_user = decoded_jwt['https://auth.rownd.io/is_verified_user']
        @is_verified_user = is_verified_user

        Devise::Rownd::Log.debug("successfully initialized user")
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
            Devise::Rownd::Log.debug("fetch_user bypassing cache")
            data = fetch_user_from_api(access_token, app_id)
            return nil unless data

            Rails.cache.write(cache_key, data, expires_in: 1.minute)
            return data
          end

          Devise::Rownd::Log.debug("fetch_user from cache if possible")
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
        return response.body['data'] if response.success?

        Devise::Rownd::Log.error("Failed to fetch user: #{response.body}")
        nil
      end
    end
  end
end
