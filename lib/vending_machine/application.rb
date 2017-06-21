module VendingMachine
  class Application
    #include VendingMachine::Currency::Sterling
    DEFAULT_PRODUCTS_LOAD = [
      { name: 'snickers', quantity: 5 },
      { name: 'diet coke', quantity: 5 },
      { name: 'twix', quantity: 5 },
      { name: 'water', quantity: 5 },
    ].freeze

    DEFAULT_CHANGE_LOAD = [
      { name: '1p', quantity: 20 },
      { name: '20p', quantity: 10 },
      { name: '50p', quantity: 5 },
    ].freeze

    DEFAULT_CATALOG_PRICES = {
      snickers: 0.60,
      'diet_coke': 0.55,
      twix: 0.65,
      water: 1.00,
    }.freeze

    STATES = %i(add_coins select_product purchase_product).freeze

    def initialize(input:, output:)
      @output = output
      @input = input
      @machine = Machine.new(products: default_products, coins: default_coins)
      @state_index = 0
    end

    def run
      loop do
        input = gets.chomp
        return if input == 'exit'
        state_index = (state_index + 1) % STATES.count if input == 'next'

        if STATES[state_index] == :add_coins
          #display_add_coins_message
        elsif STATES[state_index] == :select_product
          #display_select_product_message
        end
      end
    end

    private

    def default_products
      create_products_from_hash_array(DEFAULT_PRODUCTS_LOAD)
    end

    def default_coins
      create_coins_from_hash_array(DEFAULT_CHANGE_LOAD)
    end

    def create_products_from_hash_array(product_hash_array)
      product_hash_array.map do |product_hash|
        product_hash[:quantity].times.map do
          Product.new(name: product_hash[:name], price: DEFAULT_CATALOG_PRICES[product_hash[:name].to_sym])
        end
      end.flatten.sort_by(&:name)
    end

    def create_coins_from_hash_array(coins_hash_array)
      coins_hash_array.each do |coin_hash|
        coin_hash[:quantity].times do
          Coin.new(currency_to_number(coin_hash[:name]))
        end
      end.flatten.sort_by(&:value)
    end
  end
end
