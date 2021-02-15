require_relative 'message/base_message'
require_relative 'message/orderbook_partial'
require_relative 'message/orderbook_update'

module Ftx
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
        case message_key
          when 'orderbook_partial'
            Ftx::Message::OrderbookPartial
          when 'orderbook_update'
            Ftx::Message::OrderbookUpdate
          else
            p data
            return
        end

      klass.call(data['data']) if klass
    end

    private

    def message_key
      "#{data.dig('channel')}_#{data.dig('type')}"
    end
  end
end