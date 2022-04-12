require 'devise/rownd/api'

module Devise
  module Rownd
    include API

    def app_config
      fetch_app_config
    end

    def self.fetch_app_config
      Rails.cache.fetch("rownd_app_config", expires_in: 15.minutes) do
        response = API.make_api_call('/hub/app-config', { method: 'GET',
                                                          headers: { 'x-rownd-app-key' => app_key } })
        response.body['app'] if response.success?
      end
    end

    module_function :app_config
  end
end
