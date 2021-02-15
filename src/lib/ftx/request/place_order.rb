require_relative '../../request'

module Ftx
  module Request
    class PlaceOrder < ::Request
      attr_reader :ts, :params

      def initialize(params = {})
        @params = params
        @ts = (Time.now.to_f * 1000).to_i
      end

      def call
        @http_response = self.class.post(
          url,
          body: body,
          headers: headers
        )
        self
      end

      private

      def headers
        {
          'FTX-KEY' => ENV['FTX_API_KEY'],
          'FTX-TS' => ts.to_s,
          'FTX-SIGN' => signature
        }
      end

      def signature
        OpenSSL::HMAC.hexdigest('SHA256', ENV['FTX_API_SECRET'], signature_payload)
      end

      def signature_payload
        "#{ts}POST/api/orders#{body}"
      end

      def body
        {
          market: params[:market],
          side: params[:side],
          price: params[:price],
          type: params[:type],
          size: params[:size]
        }.to_json
      end

      def url
        "#{ENV['FTX_HOST']}orders"
      end
    end
  end
end

