require 'spec_helper'

RSpec.describe VendingMachine::Coin do
  describe '.new' do
    subject { described_class.new(value) }

    context 'when the value can represented as a coin' do
      let(:value) { 0.20 }

      it 'does not raise any error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the value is not an actual coin' do
      let(:value) { 0.15 }

      it 'raises an InvalidCoinValue error' do
        expect { subject }.to raise_error(described_class::InvalidCoinValue)
      end
    end

    context 'when the value is not a bigdecimal' do
      let(:value) { 'a' }

      it 'raises an ArgumentError error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
