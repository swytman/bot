require_relative 'message/base_message'
require_relative 'message/orderbook'

module Deribit
  class MessageParser
    attr_reader :data

    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
    end

    def call
      klass =
          case data.dig('params', 'channel')
            when 'book.BTC-PERPETUAL.none.10.100ms'
              Deribit::Message::Orderbook
            else
              p data
              return
          end

      klass.call(data.dig('params', 'data')) if klass
    end
  end
end