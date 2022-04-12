# frozen_string_literal: true

require 'faraday'
require 'faraday/net_http'
require 'faraday/retry'

module Devise::Rownd
  module API
    def conn
      @conn ||= Faraday.new('https://api.rownd.io') do |f|
        f.request :json
        f.request :retry
        f.response :json
        f.adapter :net_http
      end
    end

    def make_api_call(path, options = { method: 'GET' })
      conn.send(options[:method].downcase, path, options[:params]) do |request|
        request.body = options[:body].to_json if options[:body]
        request.headers = options[:headers] if options[:headers]
      end
    end

    module_function :conn, :make_api_call
  end
end
