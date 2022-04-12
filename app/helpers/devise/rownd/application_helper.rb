module Devise
  module Rownd
    module ApplicationHelper
      # alias devise_current_user current_user
      # alias devise_current_admin current_admin
      # alias devise_user_signed_in? user_signed_in?
      # alias devise_admin_signed_in? admin_signed_in?

      def user_signed_in?
        return true if session[:rownd_user]
      end

      def admin_signed_in?
        return true if session[:rownd_user] && session[:rownd_user]['role'] == 'admin'
      end

      def current_user
        session[:rownd_user]
      end

      def current_admin
        session[:rownd_user] if session[:rownd_user]['role'] == 'admin'
      end
    end
  end
end
