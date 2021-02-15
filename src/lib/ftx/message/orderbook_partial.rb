module Ftx
  module Message
    class OrderbookPartial < BaseMessage
      def call
        RedisConnection.set_ftx_orderbook(data.slice('bids', 'asks'))
      end
    end
  end
end
