# frozen_string_literal: true

# # ONLY NEEDED IN `classic` MODE.
# require_dependency 'devise/rownd/application_controller'

require 'devise/rownd/log'

module Devise::Rownd
  class AuthController < ApplicationController
    # Skip authenticity token verification
    skip_before_action :verify_authenticity_token, raise: false

    def authenticate
      Devise::Rownd::Log.debug('handle /authenticate')
      access_token = params[:access_token]
      session_token = session['warden.user.user.key']
      new_access_token = session_token != access_token

      Devise::Rownd::Log.debug("/authenticate: new_access_token = #{new_access_token}")

      if !session_token.nil? && new_access_token
        # We have to log the user out otherwise warden will just serialize the user from session,
        # which currently holds the old access token
        warden.logout(:user)
      end

      warden.authenticate!(scope: :user)

      should_refresh_page = new_access_token
      Devise::Rownd::Log.debug("/authenticate: success, refresh = #{should_refresh_page}")

      render json: {
        message: 'Successfully authenticated user',
        should_refresh_page:
      }, status: :ok
    end

    def sign_out
      Devise::Rownd::Log.debug('handling /sign_out')
      warden.logout(:user)
      Devise::Rownd::Log.debug('/sign_out: success')
      render json: {
        message: 'Successfully signed out user',
        return_to: return_to_after_sign_out
      }, status: :ok
    end

    def update_data
      Devise::Rownd::Log.debug('handling /update_data')
      # warden.authenticate!(scope: :user)

      request_body = JSON.parse request.body.read
      new_user = Devise::Rownd::User.new(request_body['user_data'], session['warden.user.user.key'])

      Devise::Rownd::Log.debug("/update_data: instantiated user: #{new_user}")

      warden.set_user(new_user)

      Devise::Rownd::Log.debug('/update_data: set user in warden')

      # Remove the cached user profile data so that the next next time its accessed, it will be
      # fetched from the API Server
      cache_key = "rownd_user_#{new_user.data['user_id']}"
      Rails.cache.delete(cache_key)
      Devise::Rownd::Log.debug("/update_data: removed cache key: #{cache_key}")

      render json: {
        # should_refresh_page: true
      }, status: :ok
    end

    def healthz
      render json: {
        message: 'Healthy'
      }, status: :ok
    end

    private

    def return_to_after_sign_out
      '/'
    end
  end
end
