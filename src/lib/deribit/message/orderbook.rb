require_relative '../../core/decision'

module Deribit
  module Message
    class Orderbook < BaseMessage
      def call
        orderbook = {}
        orderbook['asks'] = usd_to_btc(data['asks'])
        orderbook['bids'] = usd_to_btc(data['bids'])

        RedisConnection.set_deribit_orderbook(orderbook)
        Core::Decision.new.call
      end

      private

      def usd_to_btc(pairs)
        pairs.each do |pair|
          pair[1] = (pair[1].to_f / pair[0].to_f).round(3)
        end

        pairs
      end
    end
  end
end
