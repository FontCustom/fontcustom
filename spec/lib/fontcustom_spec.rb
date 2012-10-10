require 'spec_helper'
require 'fontcustom'

describe Fontcustom do
  let(:input_dir) { 'spec/vectors' }
  let(:output_dir) { 'spec/tmp' }

  describe 'when two params are passed' do
    before { Fontcustom.compile(input_dir, output_dir) }

    it 'must create fontcustom.css in output_dir' do
      File.exists?(output_dir + '/fontcustom.css').must_equal true
    end

    it 'stylesheet must reference the generated font files' do

    end

    it 'stylesheet must have all icon names printed as CSS classes' do
      file = File.read(output_dir + '/fontcustom.css')
      icon_names = Dir[input_dir + '/*'].map { |file| File.basename(file, '.svg').downcase }
      icon_names.each do |name|
        file.must_include('.icon-' + name)
      end
    end

    after { cleanup(output_dir) }
  end

  #describe 'when one param is passed' do
    #before { Fontcustom.compile(input_dir) }

    #it 'must compile fontcustom.css in default dir' do
      #File.exists?(File.dirname(input_dir) + '/fontcustom.css').must_equal true
    #end

    #after { cleanup(output_dir) }
  #end
end
