module VendingMachine
  class Coin
    InvalidCoinValue = Class.new(StandardError)
    ACCEPTED_VALUES = [0.01, 0.02, 0.10, 0.20, 0.50, 1.0, 2.0].freeze

    def initialize(value)
      raise InvalidCoinValue unless ACCEPTED_VALUES.include?(value)

      @value = value
    end
  end
end
