require 'spec_helper'

RSpec.describe VendingMachine::Application do
  describe '#run' do
    let(:input_source) { STDIN }
    let(:output_source) { STDOUT }
    let(:welcome_message) { 'Welcome to the Vending Machine. You can type "enter" to continue, type "?" for help or "exit" to terminate program at any time.' }
    let(:product_list_output) { "diet coke, quantity: 5\nsnickers, quantity: 5\ntwix, quantity: 5\nwater, quantity: 5" }
#     let(:product_list_output) do
#       <<~HEREDOC
# diet coke, quantity: 5
# snickers, quantity: 5
# twix, quantity: 5
# water, quantity: 5
# HEREDOC
#     end
    subject { described_class.new(input: input_source, output: output_source).run }

    context 'when command input is "exit"' do
      before { allow(input_source).to receive(:gets).twice.and_return('', 'exit') }

      it 'terminates the program without any errors' do
        subject
      end
    end

    context 'when the app is in the state of selecting a product' do
      before { allow(input_source).to receive(:gets).once.and_return('any_key', 'exit') }

      it 'prompts the user to select a product and displays the list of the products', :aggregate_failures do
        expect(output_source).to receive(:puts).with(welcome_message)
        expect(output_source).to receive(:puts).with('Please select one of the products from the list below by writing the name of the product')
        expect(output_source).to receive(:puts).with(product_list_output)

        subject
      end

      context 'when a valid product is given' do
        before do
          allow(input_source).to receive(:gets).once.and_return('any_key', 'diet coke', 'exit')
          # silence the first outputs
          allow(output_source).to receive(:puts).exactly(7).times
        end

        it 'lets the user know that the product was selected' do
          expect(output_source).to receive(:puts).with('Product Selected!')
          #expect(output_source).to receive(:puts).with('Please add one of the following coins 1p, 2p, 5p, 10p, 20p, 50p, £1, £2. e.g. enter 2p or £1')

          subject
        end

        it 'the vending machine saves the state of the selected product' do
          expect_any_instance_of(VendingMachine::Machine).to receive(:select_product).with('diet coke').and_return('diet coke')

          subject
        end
      end

      context 'when a not valid product is given' do
        before do
          allow(input_source).to receive(:gets).once.and_return('any_key', 'not_valid_product', 'exit',)
          # silence the first outputs
          allow(output_source).to receive(:puts).exactly(7).times
        end

        it 'prompts the user to try again' do
          expect(output_source).to receive(:puts).with('The product that you selected does not exist. Please select one from the list below.')
          expect(output_source).to receive(:puts).with(product_list_output)

          subject
        end
      end
    end

    context 'when the app is in the state of adding coins' do
      context 'when the user adds a valid coin' do
        before do
          allow(input_source).to receive(:gets).once.and_return('any_key', 'diet coke', '£1', 'exit')
          # silence the first outputs
          #allow(output_source).to receive(:puts).exactly(7).times
        end


      end

      context 'when the user adds an invalid coin' do
        before do
          allow(input_source).to receive(:gets).once.and_return('any_key', 'diet coke', 'is this a coin?' , 'exit')
          # silence the first outputs
          #allow(output_source).to receive(:puts).exactly(7).times
        end

        it ''
      end
    end
  end
end

