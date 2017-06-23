# frozen_string_literal: true

module VendingMachine
  class Coin
    InvalidCoinValue = Class.new(StandardError)
    ACCEPTED_VALUES = [0.01, 0.02, 0.05, 0.10, 0.20, 0.50, 1.0, 2.0].freeze

    def initialize(value)
      value = BigDecimal.new(value.to_s)
      raise InvalidCoinValue unless ACCEPTED_VALUES.include?(value.to_d)

      @value = value
    end

    attr_reader :value
  end
end
