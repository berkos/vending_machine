module VendingMachine
  class Machine
    include Currency::Pound

    DEFAULT_CATALOG = {
      snickers: 0.60,
      'diet_coke': 0.55,
      twix: 0.65,
      water: 1.00,
    }.freeze

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

    def initialize(products_batch: DEFAULT_PRODUCTS_LOAD, coins_batch: DEFAULT_CHANGE_LOAD)
      @products = []
      @coins = []
      @current_funds = []
      load_products(products_batch)
      load_change(coins_batch)
    end

    attr_reader :coins, :products

    def load_products(products_batch)
      products_batch.each do |product_batch|
        product_batch[:quantity].times do
          products.push(
            Product.new(name: product_batch[:name], price: DEFAULT_CATALOG[product_batch[:name].to_sym])
          )
        end
      end

      #products.sort_by(&:name)
    end

    def load_change(coins_batch)
      coins_batch.each do |coin_batch|
        coin_batch[:quantity].times do
          coins.push(Coin.new(currency_to_number(coin_batch[:name])))
        end
      end

      coins.sort_by(&:value)
    end

    def add_coin(value)

    end

    def purchase(product)

    end

    private

    attr_accessor :coins, :products, :current_funds

    def current_funds_value
      current_funds.sum(&:value)
    end
  end
end
