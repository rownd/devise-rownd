require 'devise/rownd/api'
require 'devise/rownd/caching'
require 'devise/rownd/log'

module Devise
  module Rownd
    include API

    def app_config
      config = Devise::Rownd::Caching.fetch('rownd_app_config', 15.minutes) { fetch_app_config }

      raise 'Failed to fetch app config' unless config

      config
    end

    def self.fetch_app_config
      response = API.make_api_call('/hub/app-config', { method: 'GET',
                                                        headers: { 'x-rownd-app-key' => app_key } })
      return response.body['app'] if response.success?

      Devise::Rownd::Log.error("Failed to fetch app config from Rownd: #{response.body['message']}")
      nil
    end

    module_function :app_config
  end
end
