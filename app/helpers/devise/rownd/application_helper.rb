require 'devise/rownd/user'

module Devise
  module Rownd
    module ApplicationHelper
      # alias devise_current_user current_user
      # alias devise_current_admin current_admin
      # alias devise_user_signed_in? user_signed_in?
      # alias devise_admin_signed_in? admin_signed_in?

      def user_signed_in?
        return true if session[:rownd_user_data]
      end

      def admin_signed_in?
        return true if session[:rownd_user_data] && session[:rownd_user_data]['role'] == 'admin'
      end

      def current_user
        User.new(session[:rownd_user_data])
      end

      def current_admin
        return current_user if current_user.admin?
      end
    end
  end
end
