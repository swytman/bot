require 'faye/websocket'
require 'eventmachine'
require_relative '../redis_connection'
require_relative 'message_parser'

module Ftx
  class Sync
    def call
      EM.run { start_connection }
    end

    private

    def start_connection
      ws = Faye::WebSocket::Client.new('wss://ftx.com/ws/', nil, ping: 15)

      ws.on :open do |_event|
        ws.send(login_command)
        ws.send(subscribe_orderbook_command)
      end

      ws.on :message do |event|
        data = JSON.parse(event.data)
        Ftx::MessageParser.call(data)
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
    end

    def login_command
      wrap_dump do
        ts = (Time.now.to_f * 1000).to_i
        {
          op: 'login', args: {
            key: ENV['FTX_API_KEY'],
            sign: mac(ts),
            time: ts
          }
        }
      end
    end

    def subscribe_orderbook_command
      wrap_dump do
        { op: 'subscribe', channel: 'orderbook', market: 'BTC-PERP' }
      end
    end

    def wrap_dump
      JSON.dump yield
    end

    def mac(ts)
      OpenSSL::HMAC.hexdigest('SHA256', ENV['FTX_API_SECRET'], "#{ts}websocket_login")
    end
  end
end