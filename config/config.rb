# Define the Passages namespace
module Devise::Rownd
  # Central configuration class
  class Config
    attr_accessor :automount
  end

  def config
    @config ||= Config.new
  end

  def configure
    yield config
  end

  module_function :config, :configure
end
