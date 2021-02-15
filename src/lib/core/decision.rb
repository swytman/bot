require_relative '../redis_connection'
require_relative 'action'

module Core
  class Decision
    attr_reader :ftx_bids, :ftx_asks, :deribit_bids, :deribit_asks, :delta

    def initialize
      ftx_orderbook = RedisConnection.fetch_ftx_orderbook
      deribit_orderbook = RedisConnection.fetch_deribit_orderbook
      @ftx_bids = ftx_orderbook.dig('bids')[0..9]
      @ftx_asks = ftx_orderbook.dig('asks')[0..9]
      @deribit_bids = deribit_orderbook.dig('bids')[0..9]
      @deribit_asks = deribit_orderbook.dig('asks')[0..9]
      @delta = ENV['DELTA'].to_f
    end

    def call
      wrap_lock do
        Core::Action.deribit_to_ftx(calc_amount_prices(deribit_asks, ftx_bids)) if diff_deribit_to_ftx > delta
        Core::Action.ftx_to_deribit(calc_amount_prices(ftx_asks, deribit_bids)) if diff_ftx_to_deribit > delta
      end
    end

    private

    def wrap_lock
      return if RedisConnection.decision_blocked?

      time_start = (Time.now.to_f * 1000).to_i
      RedisConnection.block_decision
      yield
      RedisConnection.unblock_decision
      time_end = (Time.now.to_f * 1000).to_i
      p "Decision at #{time_end - time_start}ms"
    end

    def calc_amount_prices(asks, bids)
      amount = 0
      bid_price = 0
      ask_price = 0

      while true
        if diff_percent(bids[0][0], asks[0][0]) <= delta
          return { amount: amount.round(4), bid_price: bid_price, ask_price: ask_price }
        end

        min = [bids[0][1], asks[0][1]].min
        bid_price = bids[0][0]
        ask_price = asks[0][0]
        amount += min
        bids[0][1] -= min
        asks[0][1] -= min
        bids.shift if bids[0][1].zero?
        asks.shift if asks[0][1].zero?

        if asks.size.zero? || bids.size.zero?
          return { amount: amount.round(4), bid_price: bid_price, ask_price: ask_price }
        end
      end
    end

    def diff_deribit_to_ftx
      diff_percent(ftx_bids[0][0], deribit_asks[0][0])
    end

    def diff_ftx_to_deribit
      diff_percent(deribit_bids[0][0], ftx_asks[0][0])
    end

    def diff_percent(bid, ask)
      ((bid - ask)/ask * 100).round(4)
    end

  end
end