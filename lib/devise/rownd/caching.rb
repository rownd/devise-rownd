require 'async'

module Devise::Rownd
  module Caching
    def fetch(cache_key, ttl)
      cache_val = Rails.cache.read(cache_key)

      # If there's nothing in the cache, yield the value and write it to cache
      if cache_val.nil?
        return_value = yield
        Rails.cache.write(cache_key, [return_value, Time.now]) if return_value
      else
        return_value = cache_val[0]
        last_fetch_time = cache_val[1]

        # Start a new thread to update the cached value if the TTL is exceeded
        Async do
          if Time.now - last_fetch_time > ttl
            new_value = yield
            Rails.cache.write(cache_key, [new_value, Time.now]) if new_value
          end
        end
      end

      return_value
    end

    module_function :fetch
  end
end
