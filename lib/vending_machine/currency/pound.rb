module VendingMachine
  module Currency
    class Pound
      def initialize(value)
        @value = value
      end

      attr_reader :value

      def to_s
        if value < 1.0
          "#{(value * 100).to_i}p"
        else
          "£{value}"
        end
      end
    end
  end
end
