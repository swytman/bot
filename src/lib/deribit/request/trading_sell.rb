require_relative 'base'

module Deribit
  module Request
    class TradingSell < Base
      def call
        @http_response = self.class.get(url, headers: headers)
        self
      end

      private

      def url
        "#{ENV['DERIBIT_HOST']}private/sell?" \
          "amount=#{params[:amount]}&instrument_name=#{params[:instrument_name]}&price=#{params[:price]}&" \
          "label=trading_sell&type=#{params[:type]}"
      end
    end
  end
end

