require 'rails_helper'

RSpec.describe TimeHelper, type: 'helper' do
  let(:object){
    object = Object.new
    object.extend TimeHelper
    object
  }

  describe '#time_range' do
    subject{ object.time_range from, to }

    context 'from is nil' do
      let(:from){ nil }
      it{expect{ subject }.to raise_error}
    end

    context 'from is not Time' do
      let(:from){ 'abc' }
      it{expect{ subject }.to raise_error}
    end

    context 'from is Time and has valid value(2000-01-01 11:00:00 UTC)' do
      let(:from){ Time.parse('2000-01-01 11:00:00 UTC') }

      context 'to is nil' do
        let(:to){ nil }
        it{ is_expected.to eq '11:00〜' }
      end

      context 'to is not Time' do
        let(:to){ 'abc' }
        it{ is_expected.to eq '11:00〜' }
      end

      context 'to is Time and has valid value' do
        context 'from < to(2000-01-01 23:00:00 UTC)' do
          let(:to){ Time.parse('2000-01-01 23:00:00 UTC') }
          it{ is_expected.to eq '11:00〜23:00' }
        end

        context 'from > to(2000-01-01 4:00:00 UTC)' do
          let(:to){ Time.parse('2000-01-01 4:00:00 UTC') }
          it{ is_expected.to eq '11:00〜翌4:00' }
        end
      end
    end
  end

  describe '#to_watch' do
    subject{ object.to_watch param }

    context 'parameter is not Time' do
      let(:param){ "abc" }
      it{expect{ subject }.to raise_error}
    end

    context 'parameter is nil' do
      let(:param){ nil }
      it{expect{ subject }.to raise_error}
    end

    context 'parameter is Time' do
      context 'parameter value => 2000-01-01 00:00:00 UTC' do
        let(:param){ Time.parse('2000-01-01 00:00:00 UTC') }
        it{ is_expected.to eq '0:00' }
      end

      context 'original value => 2000-01-01 03:00:00 UTC' do
          let(:param){ Time.parse('2000-01-01 03:00:00 UTC') }
          it{ is_expected.to eq '3:00' }
      end

      context 'original value => 2000-01-01 12:00:00 UTC' do
        let(:param){ Time.parse('2000-01-01 12:00:00 UTC') }
        it{ is_expected.to eq '12:00' }
      end

      context 'original value => 2000-01-01 23:00:00 UTC' do
        let(:param){ Time.parse('2000-01-01 23:00:00 UTC') }
        it{ is_expected.to eq '23:00' }
      end

      context 'original value => 2000-01-01 12:00:23 UTC' do
        let(:param){ Time.parse('2000-01-01 12:00:23 UTC') }
        it{ is_expected.to eq '12:00' }
      end
    end
  end
end
