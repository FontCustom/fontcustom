require 'spec_helper'

describe Fontcustom do
  let (:input_dir) { 'spec/fixtures/vectors' }
  let (:output_dir) { 'tmp' }

  before(:all) { Fontcustom.watch(input_dir) }

  context '#watch' do
    it 'should detect when a vector file changes' do
      `mv spec/fixtures/vectors/B.svg spec/fixtures/vectors/E.svg`
      sleep 1
      `mv spec/fixtures/vectors/E.svg spec/fixtures/vectors/B.svg`
    end

    it 'should detect when a vector file is added' do
    end

    it 'should detect when a vector file is removed' do
    end

    it 'should send complain if the dir has no vectors' do
    end
  end

  after(:all) { Fontcustom.stop }
end
