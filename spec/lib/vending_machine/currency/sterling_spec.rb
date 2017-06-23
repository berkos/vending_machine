# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VendingMachine::Currency::Sterling do
  subject { Class.new { include VendingMachine::Currency::Sterling }.new }
  describe '#number_to_currency' do
    context 'when value is nil' do
      it 'returns nil' do
        expect(subject.number_to_currency(nil)).to eq(nil)
      end
    end

    context 'when value is less than 1.0' do
      it 'returns the expected value' do
        expect(subject.number_to_currency(0.2)).to eq('20p')
      end
    end

    context 'when value is great than 1.0' do
      it 'returns the expected value' do
        expect(subject.number_to_currency(2)).to eq('£2')
      end
    end
  end

  describe '#currency_to_number' do
    context 'when value is nil' do
      it 'returns nil' do
        expect(subject.currency_to_number(nil)).to eq(nil)
      end
    end
    context 'when value contains p' do
      it 'returns the expected value' do
        expect(subject.currency_to_number('20p')).to eq(0.20)
      end
    end

    context 'when value contains £' do
      it 'returns the expected value' do
        expect(subject.currency_to_number('£2')).to eq(2.0)
      end
    end
  end
end
