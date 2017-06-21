require 'spec_helper'

RSpec.describe VendingMachine::Machine do
  describe '.new' do
    let(:coins) { [] }
    let(:products) { [] }
    subject { described_class.new(coins: coins, products: products) }

    context 'when products and coins are provided' do
      let(:coins) { [VendingMachine::Coin.new(0.02)] }
      let(:products) { [VendingMachine::Product.new(price: 0.55, name: 'twix')] }

      it 'assigns the products and coins', :aggregate_failures do
        expect(subject.coins).to match(coins)
        expect(subject.products).to match(products)
      end
    end

    context 'when wrong format of coins are provided' do
      let(:coins) { [VendingMachine::Coin.new(0.02), 'aa'] }

      it 'raises an InvalidCoins error' do
        expect { subject }.to raise_error(described_class::InvalidCoins)
      end
    end

    context 'when wrong format of coins are provided' do
      let(:products) { [VendingMachine::Product.new(price: 0.55, name: 'twix'), 'aaa'] }

      it 'raises an InvalidProducts error' do
        expect { subject }.to raise_error(described_class::InvalidProducts)
      end
    end
  end

  describe '#coins' do
    context 'when there are available coins' do
      subject { described_class.new(coins: coins) }

      let(:coins) do
        [
          VendingMachine::Coin.new(0.02),
          VendingMachine::Coin.new(1)
        ]
      end


      it 'returns the coins in an array' do
        expect(subject.coins).to match(coins)
      end
    end

    context 'when there are no available coins' do
      it 'returns an empty array' do
        expect(subject.coins).to eq([])
      end
    end
  end

  describe '#products' do
    context 'when there are available products' do
      subject { described_class.new(products: products) }

      let(:products) do
        [
          VendingMachine::Product.new(price: 0.55, name: 'twix'),
          VendingMachine::Product.new(price: 0.6, name: 'coke')
        ]
      end


      it 'returns the products in an array' do
        expect(subject.products).to match(products)
      end
    end

    context 'when there are no available products' do
      it 'returns an empty array' do
        expect(subject.products).to eq([])
      end
    end
  end

  describe '#customer_coins' do
    #TODO: write more tests
    context 'when there'
  end

  describe '#load_coins' do
    #TODO: write more tests

  end

  describe '#load_products' do
    #TODO: write more tests

  end


  describe '#add_coin' do
    let(:coin) { VendingMachine::Coin.new(0.02) }

    context 'when you pass a coin as an argument' do
      it 'adds the coin to the customer_coins', :aggregate_failures do
        subject.add_coin(coin)

        expect(subject.customer_coins).to include(coin)
        expect(subject.customer_coins_value).to eq(0.02)
      end
    end

    context 'when you do not pass a coin as an argument' do
      let(:coin) { 0.02 }

      it 'raises an error' do
        expect { subject.add_coin(coin) }.to raise_error(described_class::InvalidCoin)
      end
    end
  end

  describe '#purchase' do
    let(:product1) { VendingMachine::Product.new(price: 0.55, name: 'twix') }
    let(:product2) { VendingMachine::Product.new(price: 0.65, name: 'coke') }
    let(:products) { [product1, product2] }

    let(:coin1) { VendingMachine::Coin.new(0.05) }
    let(:coin2) { VendingMachine::Coin.new(0.10) }
    let(:coins) { [coin1, coin2] }

    subject { described_class.new(products: products, coins: coins) }

    context 'when the product not available' do
      it 'raises an ProductNotAvailable error' do
        expect { subject.purchase('Snickers') }.to raise_error(described_class::ProductNotAvailable)
      end
    end

    context 'when the product is available' do
      context 'when the customer has provided enough coins for the given product' do


        context 'when there are enough change in the machine for the customer' do
          let(:coin3) { VendingMachine::Coin.new(0.5) }
          let(:coin4) { VendingMachine::Coin.new(0.2) }

          before do
            subject.add_coin(coin3)
            subject.add_coin(coin4)
          end
          it 'returns a hash with success message along with the product and the coins' do
            expect(subject.purchase('coke')).to eq(success: true, product: product2, change: [coin1])
          end

          it 'removes the product from the vending machine list' do
            subject.purchase('coke')

            expect(subject.products).not_to include(product2)
          end

          it 'has the correct coins in the vending machine', :aggregate_failures do
            subject.purchase('coke')

            expect(subject.coins).not_to include(coin1)
            expect(subject.coins).to match_array([coin2, coin3, coin4])
            expect(subject.customer_coins).to eq([])
          end
        end

        context 'when there are not enough change in the machine for the customer' do
          let(:coin3) { VendingMachine::Coin.new(2.0) }

          before { subject.add_coin(coin3) }

          it 'returns a hash with the error' do
            expect(subject.purchase('coke')).to eq(error: 'Cannot provide correct change')
          end

          it 'does not remove the product from the vending machine list' do
            subject.purchase('coke')

            expect(subject.products).to include(product2)
          end

          it 'does not alter the existing coins of the machine' do
            subject.purchase('coke')

            expect(subject.coins).to match_array([coin1, coin2])
          end

          it 'does not take customers coins' do
            subject.purchase('coke')

            expect(subject.customer_coins).to match_array([coin3])
          end
        end
      end

      context 'when the customer has not provided enough coins for the given product' do
        let(:coin) { VendingMachine::Coin.new(0.5) }
        before { subject.add_coin(coin) }

        it 'returns a hash with an error and the remaining funds needed' do
          expect(subject.purchase('coke')).to eq(error: 'Insufficient funds', remaining_funds: 0.15)
        end
      end
    end
  end
end
