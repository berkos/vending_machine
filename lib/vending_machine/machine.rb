module VendingMachine
  class Machine
    ProductNotAvailable = Class.new(StandardError)
    InvalidCoin = Class.new(StandardError)

    DEFAULT_CATALOG = {
      snickers: 0.60,
      'diet_coke': 0.55,
      twix: 0.65,
      water: 1.00,
    }.freeze

    def initialize(products: DEFAULT_PRODUCTS_LOAD, coins_batch: DEFAULT_CHANGE_LOAD)
      @products = []
      @coins = []
      # customer coins before he exchanges them for a product
      @customer_coins = []

      load_products(products_batch)
      load_change(coins_batch)
    end

    delegate

    attr_reader :coins, :products, :customer_coins, :customer_funds

    # def create_products_from_hash_array(product_hash_array)
    #   product_hash_array.map do |product_hash|
    #     product_hash[:quantity].times.map do
    #       products.push(
    #         Product.new(name: product_hash[:name], price: DEFAULT_CATALOG[product_hash[:name].to_sym])
    #       )
    #     end
    #   end.flatten.sort_by(&:name)
    # end

    # def load_change(coins_batch)
    #   coins_batch.each do |coin_batch|
    #     coin_batch[:quantity].times do
    #       coins.push(Coin.new(currency_to_number(coin_batch[:name])))
    #     end
    #   end
    #
    #   coins.sort_by(&:value)
    # end

    def add_coin(coin)
      raise InvalidCoin unless coin.is_a?(Coin)
      customer_coins << coin
    end

    def purchase!(product_name)
      product = products.find { |product| product == product_name }
      raise ProductNotAvailable if product.nil?

      if product.value <= customer_coins_value
        # purchase the product
        product_index = products.index { |product| product == product_name }
        products.delete_at(product_index)

        change_value = customer_coins_value - product.value

        # To be implemented
        #gather_change(change_value)
        product
      else
        'Insufficient funds'
      end
    end

    def reset
      # resets the machine to the state of making a purchase
    end

    def coins_value
      coins.sum(&:value)
    end

    def customer_coins_value
      customer_coins.sum(&:value)
    end

    private

    attr_accessor :coins, :products, :funds, :customer_coins, :customer_funds

  end
end
