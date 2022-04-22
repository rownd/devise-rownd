# frozen_string_literal: true

# # ONLY NEEDED IN `classic` MODE.
# require_dependency 'devise/rownd/application_controller'

module Devise::Rownd
  class AuthController < ApplicationController
    # Skip authenticity token verification
    skip_before_action :verify_authenticity_token

    def authenticate
      @access_token = params[:access_token]

      new_access_token = session[:rownd_user_access_token] != @access_token

      session[:rownd_user_access_token] = @access_token if new_access_token

      if new_access_token || session[:rownd_stale_data] == true
        warden.logout(:user)
        warden.authenticate!(scope: :user)
      end

      render json: {
        message: 'Successfully authenticated user',
        should_refresh_page: new_access_token || session[:rownd_stale_data] == true,
      }, status: :ok
    end

    def sign_out
      session.delete(:rownd_user_access_token)
      warden.logout(:user)
      render json: {
        message: 'Successfully signed out user',
        return_to: return_to_after_sign_out
      }, status: :ok
    end

    def update_data
      session[:rownd_stale_data] = true
      warden.logout(:user)
      warden.authenticate!(scope: :user)
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
