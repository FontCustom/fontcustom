require 'spec_helper'

describe Fontcustom::StylesheetGenerator do
  let(:input_dir) { 'spec/fixtures/vectors' }
  let(:output_dir) { 'tmp' }
  let(:font_data) { Fontcustom::FontGenerator.start([input_dir, output_dir]).last }

  context 'after Fontcustom::FontGenerator runs' do
    before(:all) { Fontcustom::StylesheetGenerator.start([font_data]) }
    after(:all) { cleanup(output_dir) }

    it 'should print font-face declarations in fontcustom.css' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      files = Dir[output_dir + '/*.{woff,eot,ttf,svg}']

      files.each do |file|
        stylesheet.should include(File.basename(file))
      end
    end

    it 'should print icon-* CSS classes in fontcustom.css' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      icon_names = Dir[input_dir + '/*'].map { |file| File.basename(file, '.svg').downcase }

      icon_names.each do |name|
        stylesheet.should include('.icon-' + name)
      end
    end
  end

end
