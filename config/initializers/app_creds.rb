module Devise
  module Rownd
    def app_id
      app_config['id']
    end

    def app_schema
      app_config['schema']
    end

    def app_key
      ENV['rownd_app_key'] || ENV['ROWND_APP_KEY'] || ''
    end

    def app_secret
      ENV['rownd_app_secret'] || ENV['ROWND_APP_SECRET'] || ''
    end

    module_function :app_id, :app_schema, :app_key, :app_secret
  end
end
