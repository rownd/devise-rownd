require 'devise/rownd/user'

module Devise
  module Rownd
    module ApplicationHelper
      def show_rownd_signin_if_required
        unless flash[:rownd_alert]&.to_sym == :rownd_authentication_required
          flash.keep(:rownd_alert)
          return
        end

        render partial: 'devise/rownd/signin', locals: { rownd_return_to: session[:user_return_to] }
      end
    end
  end
end
