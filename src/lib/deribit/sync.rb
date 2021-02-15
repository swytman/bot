require 'faye/websocket'
require 'eventmachine'
require_relative '../redis_connection'
require_relative 'message_parser'

module Deribit
  class Sync
    def call
      EM.run { start_connection }
    end

    private

    def start_connection
      ws = Faye::WebSocket::Client.new(ENV['DERIBIT_WS_HOST'], nil, ping: 15)

      ws.on :open do |_event|
        ws.send(subscribe_btc)
      end

      ws.on :message do |event|
        Deribit::MessageParser.call(JSON.parse(event.data))
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
    end

    def subscribe_btc
      JSON.dump({
        jsonrpc: '2.0',
        method: 'public/subscribe',
        id: 1,
        params: {
          channels: ['book.BTC-PERPETUAL.none.10.100ms']
        }
      })
    end
  end
end