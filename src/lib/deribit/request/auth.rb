require_relative '../../request'

module Deribit
  module Request
    class Auth < ::Request
      attr_reader :client_id, :client_secret

      def initialize
        @client_id = ENV['DERIBIT_CLIENT_ID']
        @client_secret = ENV['DERIBIT_CLIENT_SECRET']
      end

      def call
        @http_response = self.class.get(url)
        self
      end

      def access_token
        parsed_response.dig('result').dig('access_token')
      end

      def expire_in
        parsed_response.dig('result').dig('expires_in')
      end

      private

      def url
        "#{ENV['DERIBIT_HOST']}public/auth?" \
          "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials"
      end
    end
  end
end

