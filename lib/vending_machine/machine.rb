module VendingMachine
  class Machine
    ProductNotAvailable = Class.new(StandardError)
    InvalidCoin = Class.new(StandardError)
    InvalidProducts = Class.new(StandardError)
    InvalidCoins = Class.new(StandardError)
    InvalidStateToAddCoin = Class.new(StandardError)

    STATES = %i(selecting_product adding_coins ready_to_purchase).freeze

    def initialize(products: [], coins: [])
      raise InvalidProducts unless products?(products)
      raise InvalidCoins unless coins?(coins)

      @products = products
      @coins = coins
      # customer coins before he exchanges them for a product
      @customer_coins = []
      @customer_selected_product = nil
      @state = STATES[0]
    end

    attr_reader :coins, :products, :customer_coins, :customer_selected_product, :state

    def add_coin(coin)
      raise InvalidStateToAddCoin unless state == :adding_coins
      raise InvalidCoin unless coin.is_a?(Coin)

      customer_coins << coin
      @state = :ready_to_purchase if remaining_customer_amount <= 0.0
    end

    def load_coins(new_coins)
      raise InvalidCoins unless coins?(new_coins)
      @coins = coins + new_coins
    end

    def load_products(new_products)
      raise InvalidProducts unless products?(new_products)
      @products = products + new_products
    end

    def purchase
      raise ProductNotAvailable if customer_selected_product.nil?

      if customer_selected_product.price <= customer_coins_value
        change_value = customer_coins_value - customer_selected_product.price
        if change_coins = find_change(change_value)
          # purchase the product
          product_index = products.index { |product| product == customer_selected_product }
          products.delete_at(product_index)

          customer_bought_product = customer_selected_product
          reset
          { success: true, product: customer_bought_product, change: change_coins }
        else
          reset
          { error: 'Cannot provide correct change' }
        end
      else
        remaining_funds = customer_selected_product.price - customer_coins_value
        { error: 'Insufficient funds', remaining_funds: remaining_funds }
      end
    end

    def remaining_customer_amount
      return 0.0 if customer_selected_product.nil?

      customer_selected_product.price - customer_coins_value
    end

    def select_product(product_name)
      @customer_selected_product = products.find { |product| product.name == product_name }
      if @customer_selected_product
        @state = :adding_coins
        true
      else
        false
      end
    end

    def coins_value
      coins.sum(&:value)
    end

    def customer_coins_value
      customer_coins.sum(&:value)
    end

    private
    attr_writer :products, :customer_funds, :customer_coins, :customer_selected_product, :coins

    def reset
      @state = :selecting_product
      @customer_coins = []
      @customer_selected_product = nil
    end

    def find_change(change_value)
      remaining_value = change_value
      change = []

      # combine customers coins and machine coins to see if you can give change,
      # make sure you get rid the large coins first so you are more flexible
      sorted_coins = (coins + customer_coins).sort_by(&:value).reverse

      sorted_coins.each_with_index do |coin, index|
        if remaining_value - coin.value >= 0
          remaining_value -= coin.value
          sorted_coins[index] = nil
          change.push(coin)
        end


        if remaining_value == 0.0
          # update coins with the new coins
          @coins = sorted_coins.compact
          @customer_coins = []
          return change
        end
      end

      # it could not find any change for the given amount and product
      return false
    end

    def products?(products)
      products.is_a?(Array) && products.all? { |product| product.is_a?(Product) }
    end

    def coins?(coins)
      coins.is_a?(Array) && coins.all? { |coin| coin.is_a?(Coin) }
    end
  end
end
