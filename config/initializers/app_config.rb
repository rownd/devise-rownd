require 'devise/rownd/api'

module Devise
  module Rownd
    include API

    def app_config
      config = Rails.cache.fetch('rownd_app_config', expires_in: 15.minutes) do
        fetched_app_config = fetch_app_config
        break unless fetched_app_config

        fetched_app_config
      end
      raise 'Failed to fetch app config' unless config

      config
    end

    def self.fetch_app_config
      response = API.make_api_call('/hub/app-config', { method: 'GET',
                                                        headers: { 'x-rownd-app-key' => app_key } })
      return response.body['app'] if response.success?

      Rails.logger.error("Failed to fetch app config from Rownd: #{response.body['message']}")
      nil
    end

    module_function :app_config
  end
end
