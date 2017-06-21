module VendingMachine
  module Currency
    module Sterling
      def number_to_currency(value)
        if value < 1.0
          "#{(value * 100).to_i}p"
        else
          "£{value}"
        end
      end

      def currency_to_number(string)
        return if string.nil?

        if string.include?('p')
          string.gsub('p', '').to_f / 100
        elsif string.include?('£')
          string.gsub('£', '').to_f
        end
      end
    end
  end
end
