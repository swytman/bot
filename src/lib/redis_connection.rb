require 'redis'
require 'json'

class RedisConnection
  class << self
    def redis
      @redis ||= Redis.new(url: 'redis://redis:6379/0')
    end

    def fetch_ftx_orderbook
      JSON.parse(RedisConnection.redis.get('ftx_orderbook'))
    end

    def set_ftx_orderbook(orderbook)
      RedisConnection.redis.set('ftx_orderbook', JSON.dump(orderbook))
    end

    def fetch_deribit_access_token
      RedisConnection.redis.get('deribit_access_token')
    end

    def set_deribit_access_token(token, ttl)
      RedisConnection.redis.set('deribit_access_token', token, ex: ttl)
    end

    def set_deribit_orderbook(orderbook)
      RedisConnection.redis.set('deribit_orderbook', JSON.dump(orderbook))
    end

    def fetch_deribit_orderbook
      JSON.parse(RedisConnection.redis.get('deribit_orderbook'))
    end

    def unblock_decision
      RedisConnection.redis.set('decision', 0)
    end

    def block_decision
      RedisConnection.redis.set('decision', 1)
    end

    def decision_blocked?
      RedisConnection.redis.get('decision') == 1
    end
  end
end