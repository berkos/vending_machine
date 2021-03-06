# frozen_string_literal: true

require_relative 'currency/sterling'

module VendingMachine
  class Application
    include Currency::Sterling
    IMAGE_PATH = 'data/vending_machine.txt'

    DEFAULT_PRODUCTS_LOAD = [
      { name: 'snickers', quantity: 5 },
      { name: 'diet coke', quantity: 5 },
      { name: 'twix', quantity: 5 },
      { name: 'water', quantity: 5 }
    ].freeze

    DEFAULT_CHANGE_LOAD = [
      { name: '1p', quantity: 20 },
      { name: '5p', quantity: 10 },
      { name: '10p', quantity: 10 },
      { name: '20p', quantity: 10 },
      { name: '50p', quantity: 5 }
    ].freeze

    DEFAULT_CATALOG_PRICES = {
      snickers: 0.60,
      'diet coke': 0.55,
      twix: 0.65,
      water: 1.00
    }.freeze

    COINS_POSITION = [
      { position: 1, coin: '1p' },
      { position: 2, coin: '2p' },
      { position: 3, coin: '5p' },
      { position: 4, coin: '10p' },
      { position: 5, coin: '20p' },
      { position: 6, coin: '50p' },
      { position: 7, coin: '£1' },
      { position: 8, coin: '£2' }
    ].freeze

    STATES = %i[select_product add_coins purchase].freeze

    def initialize(input:, output:)
      @output = output
      @input = input
      @machine = Machine.new(products: default_products, coins: default_coins)
    end

    def run
      print_vending_machine_image

      loop do
        prompt_user_for_action

        if machine.state != :ready_to_purchase
          command = input.gets.chomp
          return if terminate?(command)
        end

        output.puts('=====================================================================')
        if %w[load_products load_change].include?(command)
          pause_execution_to_load_resources(command)
        elsif command == '?'
          print_available_commands
        else
          run_command(command)
        end
        output.puts('=====================================================================')
      end
    end

    private

    attr_reader :output, :input, :machine

    def run_command(command)
      case machine.state
      when :selecting_product
        product_hash = grouped_products.find { |hash| hash[:position] == command.to_i }.to_h
        if machine.select_product(product_hash[:product_name])
          output.puts('Product Selected!')
        else
          output.puts('The product that you selected does not exist.')
        end
      when :adding_coins
        begin
          coin_name = COINS_POSITION.find { |hash| hash[:position] == command.to_i }.to_h[:coin]
          coin = Coin.new(currency_to_number(coin_name))
          machine.add_coin(coin)
          output.puts("Coin of value #{coin.value.to_f} was added!")
        rescue ArgumentError, VendingMachine::Coin::InvalidCoinValue
          output.puts('Please enter a valid coin based on the instructions below.')
        end
      when :ready_to_purchase
        output.puts('Getting the product for you..')
        result = machine.purchase
        if result.key?(:success)
          output.puts("You got the product #{result[:product].name}. And your change in coins are:")
          result[:change].each do |coin|
            output.puts(number_to_currency(coin.value).to_s)
          end
          output.puts("The value of which is £#{result[:change].sum(&:value).to_f}")
        else
          output.puts(result[:error])
          if result.key?(:remaining_funds)
            output.puts('Please provide more coins')
          else
            output.puts("Coins of value £#{machine.customer_coins_value.to_f} were returned to you.")
          end
        end
      end
    end

    def terminate?(input)
      input == 'exit'
    end

    def pause_execution_to_load_resources(command)
      if command == 'load_products'
        output.puts('Restocking with products..')
        machine.load_products(default_products)
        output.puts('done')
      elsif command == 'load_change'
        output.puts('Restocking with change..')
        machine.load_coins(default_coins)
        output.puts('done')
      end
    end

    def prompt_user_for_action
      case machine.state
      when :selecting_product
        print_welcome_message
        output.puts('Please select one of the products from the list below by writing the number which is next to it.')
        print_products_list
      when :adding_coins
        output.puts('Please add one of the following coins 1p, 2p, 5p, 10p, 20p, 50p, £1, £2.1 Select the number next to the desired coin. e.g. 2.')
        print_coins
        output.puts("You current balance is £#{machine.customer_coins_value.to_f}. The remaining amount to buy a #{machine.customer_selected_product.name} is £#{machine.remaining_customer_amount.to_f}.")
      end
    end

    def print_welcome_message
      output.puts("Welcome to the Vending Machine. type '?' for help and available commands or 'exit' to terminate program at any time.")
    end

    def print_vending_machine_image
      File.readlines(IMAGE_PATH).each do |line|
        output.puts(line)
      end
    end

    def print_available_commands
      output.puts('exit - Terminates the program')
      output.puts('load_products - Adds extra stock to the vending machine with the default quantity of products.')
      output.puts('load_coins - Adds extra change to the vending machine with the default coins.')
      output.puts('? - help')
      output.puts('There are more available commands based on the state of the vending machine(Instructions will be given).')
    end

    def print_products_list
      grouped_products.each do |hash|
        output.puts "#{hash[:position]}. #{hash[:product_name]}, price: £#{hash[:price]}, quantity: #{hash[:quantity]}"
      end
    end

    def print_coins
      COINS_POSITION.each do |hash|
        output.puts("#{hash[:position]}. #{hash[:coin]}")
      end
    end

    def grouped_products
      count = 0
      machine.products.group_by(&:name).map do |product_name, products|
        count += 1
        { position: count, product_name: product_name, price: products.first.price.to_f, quantity: products.count }
      end
    end

    def default_products
      create_products_from_hash_array(DEFAULT_PRODUCTS_LOAD)
    end

    def default_coins
      create_coins_from_hash_array(DEFAULT_CHANGE_LOAD)
    end

    def create_products_from_hash_array(product_hash_array)
      product_hash_array.map do |product_hash|
        Array.new(product_hash[:quantity]) do
          Product.new(name: product_hash[:name], price: DEFAULT_CATALOG_PRICES[product_hash[:name].to_sym])
        end
      end.flatten.sort_by(&:name)
    end

    def create_coins_from_hash_array(coins_hash_array)
      coins_hash_array.map do |coin_hash|
        Array.new(coin_hash[:quantity]) do
          Coin.new(currency_to_number(coin_hash[:name]))
        end
      end.flatten.sort_by(&:value)
    end
  end
end
