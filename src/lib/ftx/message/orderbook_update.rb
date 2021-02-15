module Ftx
  module Message
    class OrderbookUpdate < BaseMessage
      def call
        orderbook = RedisConnection.fetch_ftx_orderbook
        orderbook['asks'] = update_data(orderbook['asks'], data['asks'], 1)
        orderbook['bids'] = update_data(orderbook['bids'], data['bids'], -1)

        RedisConnection.set_ftx_orderbook(orderbook)
      end

      private

      def update_data(orderbook, changes, direction)
        orderbook = orderbook.to_h
        changes.to_h.each do |price, amount|
          orderbook[price.to_f] = amount
        end

        orderbook = orderbook.sort_by { |price, _amount| price.to_f * direction }
        orderbook.map! { |pair| [pair[0].to_f, pair[1]] unless pair[1].zero? }.compact
      end
    end
  end
end
