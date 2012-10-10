require 'spec_helper'
require 'fontcustom'

describe Fontcustom do
  let(:input_dir) { 'spec/vectors' }
  let(:output_dir) { 'spec/tmp' }

  before do
    Fontcustom.compile(input_dir, :output => output_dir, :verbose => false)
  end

  describe Fontcustom::FontGenerator do
    it 'must create webfonts in output_dir' do
      exts = %w( .woff .eot .ttf .svg )
      fonts = Dir[output_dir + '/*'].delete_if { |file| File.extname(file) == '.css' }

      fonts.each do |font|
        exts.include?(File.extname(font)).must_equal true
      end
    end
  end

  describe Fontcustom::StylesheetGenerator do
    it 'must create fontcustom.css in output_dir' do
      File.exists?(output_dir + '/fontcustom.css').must_equal true
    end

    it 'stylesheet must reference the generated font files' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      files = Dir[output_dir + '/*']
      files.delete_if do |file|
        ext = File.extname(file)
        ext == '.css' || ext == '.otf'
      end

      files.each do |file|
        stylesheet.must_include(File.basename(file))
      end
    end

    it 'stylesheet must have all icon names printed as CSS classes' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      icon_names = Dir[input_dir + '/*'].map { |file| File.basename(file, '.svg').downcase }

      icon_names.each do |name|
        stylesheet.must_include('.icon-' + name)
      end
    end

  end

  after { cleanup(output_dir) }
end
