require 'spec_helper'

describe Fontcustom do
  let(:input_dir) { 'spec/fixtures/vectors' }
  let(:output_dir) { 'tmp' }

  context 'when ouput_dir already contains files' do
    before(:all) do
      # create extra fake file
    end

    it 'should delete previous fontcustom generated files' do

    end

    it 'should not delete non-fontcustom generated files' do

    end

  end
end
