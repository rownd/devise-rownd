module Devise
  module Rownd
    class Engine < ::Rails::Engine
      isolate_namespace Devise::Rownd

      # TODO: Add this to the devise config
      # Look into rails generate devise:install which creates the
      # initializers/devise.rb file
      # config.skip_session_storage = [:http_auth]

      # mount devise-rownd to the application
      initializer('devise-rownd.mount', after: :load_config_initializers) do |_app|
        if Devise::Rownd.config.automount
          Rails.application.routes.prepend do
            mount Devise::Rownd::Engine, at: '/api/auth/rownd'
          end
        end
      end

      # add the custom failure app to warden config
      initializer('devise-rownd.devise_failure_app', after: :load_config_initializers) do |_app|
        Devise.setup do |config|
          require 'devise/rownd/custom_failure'
          config.warden do |manager|
            manager.failure_app = Devise::Rownd::CustomAuthFailure
          end
        end
      end

      # load devise-rownd helpers into the application
      config.to_prepare do
        ::ApplicationController.helper Devise::Rownd::ApplicationHelper
      end
    end
  end
end
