# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VendingMachine::Product do
  let(:arguments) { { price: 0.60, name: 'Snickers' } }
  subject { described_class.new(arguments) }

  describe '#value' do
    it 'returns the correct value' do
      expect(subject.price).to eq(arguments[:price])
    end
  end

  describe '#name' do
    it 'returns the correct value' do
      expect(subject.name).to eq(arguments[:name])
    end
  end

  describe '#to_s' do
    context 'when the value is less than a '
  end
end
