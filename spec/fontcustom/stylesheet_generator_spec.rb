require 'spec_helper'

describe Fontcustom::StylesheetGenerator do
  let(:icon_names) { ['walrus', 'giraffe', 'mongoose'] }
  let(:output_dir) { 'spec/tmp' }

  before { @names = Fontcustom::StylesheetGenerator.start([icon_names, output_dir]) }

  it 'must create a stylesheet' do
    File.exists?(output_dir + '/fontcustom.css').must_equal true
  end

  it 'must have all icon names printed as CSS classes' do
    file = File.read(output_dir + '/fontcustom.css')
    icon_names.each do |name|
      file.must_include('.icon-' + name)
    end
  end

  after { cleanup(output_dir) }
end
