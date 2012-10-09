require 'spec_helper'

describe Fontcustom::FontGenerator do
  let(:input_dir) { 'spec/vectors' }
  let(:output_dir) { 'spec/tmp' }

  before { @names = Fontcustom::FontGenerator.start([input_dir, output_dir]) }

  it 'must create a directory full of webfonts' do
    Dir[output_dir + '/*'].wont_be_empty
  end

  it 'must return an array of icon names' do
    @names.wont_be_empty
  end

  after { cleanup(output_dir) }
end
