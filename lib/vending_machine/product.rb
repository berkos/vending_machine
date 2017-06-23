# frozen_string_literal: true

module VendingMachine
  class Product
    def initialize(price:, name:)
      @price = price
      @name = name
    end

    attr_reader :price, :name
  end
end
