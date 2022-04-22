module Devise
  module Rownd
    class CustomAuthFailure < Devise::FailureApp
      def redirect
        store_location!
        if is_flashing_format?
          if flash[:timedout] && flash[:alert]
            flash.keep(:timedout)
            flash.keep(:alert)
          else
            key = i18n_message == :rownd_authentication_required ? :rownd_alert : :alert
            flash[key] = i18n_message
          end
        end
        redirect_to redirect_url
      end

      def i18n_message(default = nil)
        message = warden_message || default || :unauthenticated

        return :rownd_authentication_required if message.to_sym == :unauthenticated

        super(default)
      end
    end 
  end
end
