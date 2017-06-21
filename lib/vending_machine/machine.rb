module VendingMachine
  class Machine
    ProductNotAvailable = Class.new(StandardError)
    InvalidCoin = Class.new(StandardError)
    InvalidProducts = Class.new(StandardError)
    InvalidCoins = Class.new(StandardError)

    def initialize(products: [], coins: [])
      raise InvalidProducts unless products?(products)
      raise InvalidCoins unless coins?(coins)

      #raise unless coins
      @products = products
      @coins = coins
      # customer coins before he exchanges them for a product
      @customer_coins = []
      @customer_selected_product = nil
    end

    attr_reader :coins, :products, :customer_coins, :customer_selected_product

    def add_coin(coin)
      raise InvalidCoin unless coin.is_a?(Coin)
      customer_coins << coin
    end

    def load_coins(new_coins)
      @coins = coins + new_coins
    end

    def load_products(new_products)
      @products = products + new_products
    end

    def purchase(product_name)
      product = products.find { |product| product.name == product_name }
      raise ProductNotAvailable if product.nil?

      if product.price <= customer_coins_value
        change_value = customer_coins_value - product.price
        if change_coins = find_change(change_value)
          # purchase the product
          product_index = products.index { |product| product.name == product_name }
          products.delete_at(product_index)
          # remove customers coins

          # To be implemented
          reset
          { success: true, product: product, change: change_coins }
        else
          reset
          { error: 'Cannot provide correct change' }
        end
      else
        remaining_funds = product.price - customer_coins_value
        { error: 'Insufficient funds', remaining_funds: remaining_funds }
      end
    end

    def reset
      # resets the machine to the state of making a purchase
      # returns the coins??
      @customer_coins = []
      @customer_selected_product = nil
    end

    def remaining_customer_amount
      return nil if customer_selected_product.nil?

      customer_selected_product.price - customer_coins_value
    end

    def select_product(product_name)
      @customer_selected_product = products.find { |product| product.name == product_name }
    end

    def coins_value
      coins.sum(&:value)
    end

    def customer_coins_value
      customer_coins.sum(&:value)
    end

    private
    attr_accessor :coins
    attr_writer :products, :customer_funds, :customer_coins, :customer_selected_product

    def find_change(change_value)
      remaining_value = change_value
      change = []

      # combine customers coins and machine coins to see if you can give change,
      # make sure you get rid the large coins so you are more flexible
      sorted_coins = (coins + customer_coins).sort_by(&:value)

      sorted_coins.reverse.each_with_index do |coin, index|
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
