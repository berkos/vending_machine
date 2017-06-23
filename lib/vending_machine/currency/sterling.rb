# frozen_string_literal: true

module VendingMachine
  module Currency
    module Sterling
      def number_to_currency(value)
        return if value.nil?

        if value < 1.0
          "#{(value * 100).to_i}p"
        else
          "£#{value}"
        end
      end

      def currency_to_number(string)
        return if string.nil?

        if string.include?('p')
          string.delete('p').to_f / 100
        elsif string.include?('£')
          string.delete('£').to_f
        end
      end
    end
  end
end
