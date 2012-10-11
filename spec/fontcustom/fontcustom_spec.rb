require 'spec_helper'

describe Fontcustom do
  let(:input_dir) { 'spec/fixtures/vectors' }
  let(:output_dir) { 'tmp' }

  before(:all) do
    Fontcustom.compile(input_dir, output_dir, :verbose => false)
  end

  context '#compile' do
    it 'should create webfonts in output_dir' do
      exts = %w( .woff .eot .ttf .svg )
      fonts = Dir[output_dir + '/*'].delete_if { |file| File.extname(file) == '.css' }
      fonts.map! { |font| File.extname(font) }

      exts.each do |type|
        fonts.should include(type)
      end
    end

    it 'should create fontcustom.css in output_dir' do
      File.exists?(output_dir + '/fontcustom.css').should be_true
    end

    it 'should print font-face declarations in fontcustom.css' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      files = Dir[output_dir + '/*']
      files.delete_if do |file|
        ext = File.extname(file)
        ext == '.css' || ext == '.otf'
      end

      files.each do |file|
        stylesheet.should include(File.basename(file))
      end
    end

    it 'should print icon CSS classes in fontcustom.css' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      icon_names = Dir[input_dir + '/*'].map { |file| File.basename(file, '.svg').downcase }

      icon_names.each do |name|
        stylesheet.should include('.icon-' + name)
      end
    end
  end

  after(:all) { cleanup(output_dir) }
end
