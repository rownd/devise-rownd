# frozen_string_literal: true

require 'jose'

require 'devise/rownd/api'

require_relative '../../../../config/initializers/app_creds'

# # ONLY NEEDED IN `classic` MODE.
# require_dependency 'devise/rownd/application_controller'

Faraday.default_adapter = :net_http

module Devise::Rownd
  include API

  class AuthController < ApplicationController
    # Skip authenticity token verification
    skip_before_action :verify_authenticity_token

    def authenticate
      @access_token = params[:access_token]
      @user = fetch_user

      configured_app_id = Devise::Rownd.app_id
      ok = app_id == configured_app_id
      return render json: { error: 'JWT not authorized for app' }, status: :unauthorized unless ok

      should_refresh_page = !(session[:rownd_user_data] && session[:rownd_user_data]['user_id'] == @user['user_id'])

      set_session_on_authentication

      render json: {
        message: 'Successfully authenticated user',
        should_refresh_page: should_refresh_page
      }, status: :ok
    end

    def sign_out
      session[:rownd_user_data] = nil
      session[:rownd_app_id] = nil
      session[:rownd_app_user_id] = nil
      session[:rownd_user_access_token] = nil
      render json: {
        message: 'Successfully signed out user',
        return_to: return_to_after_sign_out
      }, status: :ok
    end

    def healthz
      render json: {
        message: 'Healthy'
      }, status: :ok
    end

    private

    def verify_user_for_app
      configured_app_id = Devise::Rownd.app_id
      return false unless app_id == configured_app_id
    end

    def set_session_on_authentication
      session[:rownd_user_data] = @user
      session[:rownd_app_id] = app_id
      session[:rownd_app_user_id] = @user['user_id']
      session[:rownd_user_access_token] = @access_token
    end

    def return_to_after_sign_out
      '/'
    end

    def fetch_user
      response = API.make_api_call(
        "/me/applications/#{app_id}/data",
        {
          method: 'GET',
          headers: { 'Authorization' => "Bearer #{@access_token}" }
        }
      )
      return response.body['data'] if response.success?

      raise StandardError, response.body['message']
    end

    def app_id
      @app_id ||= decoded_jwt['aud'].find(/^app:.+/).first.split(':').last
    end

    def decoded_jwt
      @decoded_jwt ||= verify_token(@access_token)
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
      response = API.make_api_call('/hub/auth/keys')
      response.body['keys']
    end
  end
end
