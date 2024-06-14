require 'async'
require 'devise/rownd/log'

module Devise::Rownd
  module Caching
    def fetch(cache_key, ttl)
      cache_val = Rails.cache.read(cache_key)

      # If there's nothing in the cache, yield the value and write it to cache
      if cache_val.nil?
        Devise::Rownd::Log.debug("cache: key not found '#{cache_key}'")
        return_value = yield
        if return_value
          Devise::Rownd::Log.debug("cache: updating cache. '#{cache_key}' value: #{return_value}")
          Rails.cache.write(cache_key, [return_value, Time.now]) if return_value
        end
      else
        Devise::Rownd::Log.debug("cache: key found: '#{cache_key}'")
        return_value = cache_val[0]
        last_fetch_time = cache_val[1]

        # Start a new thread to update the cached value if the TTL is exceeded
        Async do
          begin
            if Time.now - last_fetch_time > ttl
              new_value = yield
              Devise::Rownd::Log.debug("cache: updating cache. '#{cache_key}' value: #{new_value}")
              Rails.cache.write(cache_key, [new_value, Time.now]) if new_value
            end
          rescue StandardError => e
            Devise::Rownd::Log.error("cache: failed updating cache: #{e.message}")
          end
        end
      end

      return_value
    end

    module_function :fetch
  end
end
