module Devise
  module Rownd
    class Engine < ::Rails::Engine
      isolate_namespace Devise::Rownd

      # TODO: Add this to the devise config
      # Look into rails generate devise:install which creates the
      # initializers/devise.rb file
      # config.skip_session_storage = [:http_auth]

      # mount devise-rownd to the application
      initializer('devise-rownd.mount', after: :load_config_initializers) do |app|
        if Devise::Rownd.config.automount
          Rails.application.routes.prepend do
            mount Devise::Rownd::Engine, at: '/api/auth/rownd'
          end
        end
      end

      # load devise-rownd helpers into the application
      initializer('devise-rownd.helpers', after: :load_config_initializers) do |app|
        ActiveSupport.on_load :action_controller do
          helper Devise::Rownd::ApplicationHelper
        end
      end
    end
  end
end
