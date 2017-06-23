# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VendingMachine::Application do
  describe '#run' do
    let(:input_source) { double('STDIN') }
    let(:output_source) { double('STDOUT') }
    before do
      allow(input_source).to receive(:gets).and_return(*command)
      allow(output_source).to receive(:puts)
    end

    let(:welcome_message) { 'Welcome to the Vending Machine. You can type "enter" to continue, type "?" for help or "exit" to terminate program at any time.' }
    subject { described_class.new(input: input_source, output: output_source).run }

    context 'when command input is "exit"' do
      let(:command) { %w(exit) }

      it 'terminates the program without any errors' do
        subject
      end
    end

    context 'when the machine is in the state of selecting a product' do
      context 'when a valid product is given' do
        let(:command) { %w(1 exit) }

        it 'vending machine saves the state of the selected product' do
          expect_any_instance_of(VendingMachine::Machine).to receive(:select_product).with('diet coke').and_call_original

          subject
        end
      end

      context 'when a not valid product is given' do
        let(:command) { %w(wrong_product exit) }

        it 'vending machine does not selects a product' do
          expect_any_instance_of(VendingMachine::Machine).to receive(:select_product).and_call_original

          subject
        end
      end
    end

    context 'when the app is in the state of :adding_coins' do
      let(:command) { %w(1 8 exit) }

      context 'when the user adds a valid coin from the selection' do
        it 'adds a coin to the machine' do
          expect_any_instance_of(VendingMachine::Machine).to receive(:add_coin).and_call_original
          subject
        end
      end

      context 'when the user adds an invalid coin' do
        let(:command) { %w(1 not correct command exit) }

        it 'does not adds a coin to the machine' do
          expect_any_instance_of(VendingMachine::Machine).not_to receive(:add_coin)
          subject
        end
      end
    end

    context 'when the app is in the state of :ready_to_purchase' do
      let(:command) { %w(1 1 2 8 exit) }

      it 'calls vending machine to purchase and responds with the correct hash' do
        expect_any_instance_of(VendingMachine::Machine).to receive(:purchase).and_call_original
        subject
      end
    end
  end
end
