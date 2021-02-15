require_relative '../ftx/request/place_order'
require_relative '../deribit/request/trading_buy'
require_relative '../deribit/request/trading_sell'

module Core
  class Action
    class << self
      def deribit_to_ftx(params)
        p '=' * 20
        p "BUY #{params[:amount]} at #{params[:ask_price]} on Deribit"
        p "SELL #{params[:amount]} at #{params[:bid_price]} on FTX"

        buy_thread = Thread.new { place_deribit_buy(params[:amount], params[:ask_price]) }
        sell_thread = Thread.new { place_ftx_order(params[:amount], params[:bid_price], 'sell') }
        [buy_thread, sell_thread].each(&:join)
      end

      def ftx_to_deribit(params)
        p '=' * 20
        p "BUY #{params[:amount]} at #{params[:ask_price]} on FTX"
        p "SELL #{params[:amount]} at #{params[:bid_price]} on Deribit"

        buy_thread = Thread.new { place_ftx_order(params[:amount], params[:ask_price], 'buy') }
        sell_thread = Thread.new { place_deribit_sell(params[:amount], params[:bid_price]) }
        [buy_thread, sell_thread].each(&:join)
      end

      def place_ftx_order(amount, price, side)
        request = Ftx::Request::PlaceOrder.new(
          market: 'BTC-PERP',
          side: side,
          price: price,
          type: 'limit',
          size: amount
        ).call

        response_message('FTX', request)
      end

      def place_deribit_sell(amount, price)
        request = Deribit::Request::TradingSell.new(
          instrument_name: 'BTC-PERPETUAL',
          price: price,
          type: 'limit',
          amount: round_to_contract_size(amount, price)
        ).call

        response_message('DERIBIT', request)
      end

      def place_deribit_buy(amount, price)
        request = Deribit::Request::TradingBuy.new(
          instrument_name: 'BTC-PERPETUAL',
          price: price,
          type: 'limit',
          amount: round_to_contract_size(amount, price)
        ).call

        response_message('DERIBIT', request)
      end

      def response_message(exchange, request)
        if request.success_response?
          p "#{exchange} responsed OK"
        else
          p "#{exchange} response #{request.status}"
          pp request.parsed_response
        end
      end

      def round_to_contract_size(amount, price)
        (amount * price / 10).ceil * 10.0
      end
    end
  end
end