module Devise::Rownd
  def app_id
    ENV['rownd_app_id'] || ENV['ROWND_APP_ID'] || ''
  end

  def app_key
    ENV['rownd_app_key'] || ENV['ROWND_APP_KEY'] || ''
  end

  def app_secret
    ENV['rownd_app_secret'] || ENV['ROWND_APP_SECRET'] || ''
  end

  module_function :app_id, :app_key, :app_secret
end
