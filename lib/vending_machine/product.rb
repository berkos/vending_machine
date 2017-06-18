module VendingMachine
  class Product
    def initialize(value:, name:)
      @value = value
      @name = name
    end

    attr_reader :value, :name
  end
end
