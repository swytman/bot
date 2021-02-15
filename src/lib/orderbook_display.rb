require_relative 'redis_connection'
require 'pp'

while true
  p '--- FTX ----'
  pp RedisConnection.fetch_ftx_orderbook
  p '--- Deribit ----'
  pp RedisConnection.fetch_deribit_orderbook
  sleep(5)
end
