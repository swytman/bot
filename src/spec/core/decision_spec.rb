require 'rspec'
require 'fakeredis'

require_relative '../../lib/core/decision'

describe Core::Decision do
  let(:decision) { described_class.new }

  context 'calc_amount_prices alg' do
    before do
      RedisConnection.set_ftx_orderbook(bids: [], asks: [])
      RedisConnection.set_deribit_orderbook(bids: [], asks: [])
      allow_any_instance_of(described_class).to receive(:delta).and_return(0)
    end

    context 'asks bids set 1' do
      let(:asks) { [[9.0, 2], [10.0, 1], [11.0, 2], [12.0, 5], [13.0, 100]] }
      let(:bids) { [[12.0, 10], [11.0, 5], [10.0, 1], [9.0, 100]] }
      let(:answer) { { amount: 5, ask_price: 11.0, bid_price: 12.0 } }

      it 'should return correct decision' do
        expect(decision.send(:calc_amount_prices, asks, bids)).to eq(answer)
      end
    end

    context 'asks bids set 2' do
      let(:asks) { [[9.0, 100], [10.0, 1], [11.0, 2], [12.0, 5]] }
      let(:bids) { [[12.0, 10], [11.0, 5], [10.0, 1], [9.0, 100]] }
      let(:answer) { { amount: 16, ask_price: 9.0, bid_price: 10.0 } }

      it 'should return correct decision' do
        expect(decision.send(:calc_amount_prices, asks, bids)).to eq(answer)
      end
    end

    context 'asks bids set 2' do
      let(:asks) { [[13.0, 100], [14.0, 1], [15.0, 2], [16.0, 5]] }
      let(:bids) { [[12.0, 10], [11.0, 5], [10.0, 1], [9.0, 100]] }
      let(:answer) { { amount: 0, ask_price: 0, bid_price: 0 } }

      it 'should return correct decision' do
        expect(decision.send(:calc_amount_prices, asks, bids)).to eq(answer)
      end
    end
  end
end