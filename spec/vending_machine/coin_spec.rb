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

    context 'when the value can not represented as a coin' do
      let(:value) { 0.15 }

      it 'raises an InvalidCoinValue error' do
        expect { subject }.to raise_error(described_class::InvalidCoinValue)
      end
    end
  end
end
