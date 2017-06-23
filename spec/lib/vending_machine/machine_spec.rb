# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VendingMachine::Machine do
  let(:coins) { [VendingMachine::Coin.new(0.02)] }
  let(:products) { [VendingMachine::Product.new(price: 0.55, name: 'twix')] }
  subject { described_class.new(coins: coins, products: products) }

  describe '.new' do
    context 'when products and coins are provided' do
      it "assigns the products and coins and set's the machine state to :selecting_product", :aggregate_failures do
        expect(subject.coins).to match(coins)
        expect(subject.products).to match(products)
        expect(subject.state).to eq(:selecting_product)
      end

      it 'customer coins are empty and there is no customer selected product', :aggregate_failures do
        expect(subject.customer_coins).to eq([])
        expect(subject.customer_selected_product).to be_nil
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

  describe '#select_product' do
    let(:products) { [VendingMachine::Product.new(price: 0.55, name: 'twix')] }
    subject { described_class.new(products: products) }

    context 'when the product is available' do
      it 'returns true' do
        expect(subject.select_product('twix')).to eq(true)
      end

      it 'alters the state of the machine from to :adding_coins' do
        expect { subject.select_product('twix') }.to change { subject.state }.from(:selecting_product).to(:adding_coins)
      end
    end

    context 'when the product is not available' do
      it 'returns false' do
        expect(subject.select_product('snickers')).to eq(false)
      end

      it 'does alters the state of the machine from to :adding_coins' do
        expect { subject.select_product('snickers') }.not_to change { subject.state }.from(:selecting_product)
      end
    end
  end

  describe '#coins' do
    context 'when there are available coins' do
      it 'returns the coins in an array' do
        expect(subject.coins).to match(coins)
      end
    end

    context 'when there are no available coins' do
      let(:coins) { [] }
      it 'returns an empty array' do
        expect(subject.coins).to eq([])
      end
    end
  end

  describe '#products' do
    context 'when there are available products' do
      it 'returns the products in an array' do
        expect(subject.products).to match(products)
      end
    end

    context 'when there are no available products' do
      let(:products) { [] }
      it 'returns an empty array' do
        expect(subject.products).to eq([])
      end
    end
  end

  describe '#customer_coins' do
    subject { described_class.new(products: products, coins: coins) }
    let(:customer_coins) { [VendingMachine::Coin.new(0.05), VendingMachine::Coin.new(0.10)] }

    before do
      subject.select_product('twix')
      customer_coins.each do |coin|
        subject.add_coin(coin)
      end
    end

    it 'holds the coins that customer has inserted' do
      expect(subject.customer_coins).to match_array(customer_coins)
    end
  end

  describe '#add_coin' do
    let(:coin) { VendingMachine::Coin.new(0.02) }

    context 'when a product is not selected' do
      it 'raises an error' do
        expect { subject.add_coin(coin) }.to raise_error(described_class::InvalidStateToAddCoin)
      end
    end

    context 'when a product is selected' do
      before { subject.select_product('twix') }

      context 'when you pass a coin as an argument' do
        it 'adds the coin to the customer_coins', :aggregate_failures do
          subject.add_coin(coin)

          expect(subject.customer_coins).to include(coin)
          expect(subject.customer_coins_value).to eq(0.02)
        end

        context 'when the remaining customer amount get zero or less' do
          let(:coin) { VendingMachine::Coin.new(2.00) }

          it 'changes the state of the machine to :ready_to_purchase' do
            expect { subject.add_coin(coin) }.to change { subject.state }.from(:adding_coins).to(:ready_to_purchase)
          end
        end
      end
      context 'when you do not pass a coin as an argument' do
        let(:coin) { 0.02 }

        it 'raises an error' do
          expect { subject.add_coin(coin) }.to raise_error(described_class::InvalidCoin)
        end
      end
    end
  end

  describe '#load_coins' do
    context 'when coins are passed' do
      let(:new_coins) { [VendingMachine::Coin.new(0.05), VendingMachine::Coin.new(0.10)] }

      it 'stocks the machine with the extra coins' do
        subject.load_coins(new_coins)

        expect(subject.coins).to match_array(coins + new_coins)
      end
    end

    context 'when coins in wrong format are passed' do
      let(:new_coins) { [VendingMachine::Coin.new(0.05), 'not a coin!', VendingMachine::Coin.new(0.10)] }

      it 'raises an error' do
        expect { subject.load_coins(new_coins) }.to raise_error(described_class::InvalidCoins)
      end
    end
  end

  describe '#load_products' do
    context 'when coins are passed' do
      let(:new_products) { [VendingMachine::Product.new(price: 0.55, name: 'twix'), VendingMachine::Product.new(price: 0.65, name: 'coke')] }

      it 'stocks the machine with the extra products' do
        subject.load_products(new_products)

        expect(subject.products).to match_array(products + new_products)
      end
    end

    context 'when coins in wrong format are passed' do
      let(:new_coins) { [VendingMachine::Coin.new(0.05), 'not a coin!', VendingMachine::Coin.new(0.10)] }

      it 'raises an error' do
        expect { subject.load_coins(new_coins) }.to raise_error(described_class::InvalidCoins)
      end
    end
  end

  describe '#remaining_customer_amount' do
    context 'when customer has not selected a product' do
      it 'returns 0.0' do
        expect(subject.remaining_customer_amount).to eq(0.0)
      end
    end

    context 'when customer has selected a product and has added some coins too' do
      before do
        subject.select_product('twix')
        subject.add_coin(VendingMachine::Coin.new(0.05))
        subject.add_coin(VendingMachine::Coin.new(0.20))
      end

      it 'returns the remaining amount that the customer has to pay' do
        expect(subject.remaining_customer_amount).to eq(0.30)
      end
    end
  end

  describe '#coins_value' do
    it 'returns the sum of value for the coins' do
      expect(subject.coins_value).to eq(coins.sum(&:value))
    end
  end

  describe '#customer_coins_value' do
    let(:customer_coins) { [VendingMachine::Coin.new(0.05), VendingMachine::Coin.new(0.10)] }

    before do
      subject.select_product('twix')
      customer_coins.each do |coin|
        subject.add_coin(coin)
      end
    end

    it 'returns the sum of value for the customer coins' do
      expect(subject.customer_coins_value).to eq(customer_coins.sum(&:value))
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

    context 'when the product is available' do
      context 'when the customer has provided enough coins for the given product' do
        context 'when there are enough change in the machine for the customer' do
          let(:coin3) { VendingMachine::Coin.new(0.5) }
          let(:coin4) { VendingMachine::Coin.new(0.2) }

          before do
            subject.select_product('coke')
            subject.add_coin(coin3)
            subject.add_coin(coin4)
          end

          it 'returns a hash with success message along with the product and the coins' do
            expect(subject.purchase).to eq(success: true, product: product2, change: [coin1])
          end

          it 'changes the state of the machine from :ready_to_purchase to :selecting_product' do
            expect { subject.purchase }.to change { subject.state }.from(:ready_to_purchase).to(:selecting_product)
          end

          it 'removes the product from the vending machine list' do
            subject.purchase

            expect(subject.products).not_to include(product2)
          end

          it 'has the correct coins in the vending machine', :aggregate_failures do
            subject.purchase

            expect(subject.coins).not_to include(coin1)
            expect(subject.coins).to match_array([coin2, coin3, coin4])
            expect(subject.customer_coins).to eq([])
          end
        end

        context 'when there are not enough change in the machine for the customer' do
          let(:coin3) { VendingMachine::Coin.new(2.0) }

          before do
            subject.select_product('coke')
            subject.add_coin(coin3)
          end

          it 'returns a hash with the error' do
            expect(subject.purchase).to eq(error: 'Cannot provide correct change')
          end

          it 'does not remove the product from the vending machine list' do
            subject.purchase

            expect(subject.products).to include(product2)
          end

          it 'does not alter the existing coins of the machine' do
            subject.purchase

            expect(subject.coins).to match_array([coin1, coin2])
          end

          it 'does not take customers coins' do
            subject.purchase

            expect(subject.customer_coins).not_to match_array([coin3])
          end
        end
      end

      context 'when the customer has not provided enough coins for the given product' do
        let(:coin) { VendingMachine::Coin.new(0.5) }
        before do
          subject.select_product('coke')
          subject.add_coin(coin)
        end

        it 'returns a hash with an error and the remaining funds needed' do
          expect(subject.purchase).to eq(error: 'Insufficient funds', remaining_funds: 0.15)
        end

        it 'does not changes the state of the machine from :ready_to_purchase to :selecting_product' do
          expect { subject.purchase }.not_to change { subject.state }
        end
      end
    end
  end
end
