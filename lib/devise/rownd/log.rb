module Devise::Rownd
  module Log
    @logger ||= ActiveSupport::TaggedLogging.new(Logger.new(($stdout))) if (ENV['rownd_debug'] || ENV['ROWND_DEBUG']) == 'true'

    def self.debug(message)
      return unless @logger

      @logger.tagged('Rownd') { @logger.debug(message) }
    end

    def self.error(message)
      return unless @logger

      @logger.tagged('Rownd') { @logger.error(message) }
    end
  end
end
