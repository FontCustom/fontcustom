require 'spec_helper'

describe Fontcustom::Generator do
  let(:input_dir) { 'spec/fixtures/vectors' }
  let(:output_dir) { 'tmp' }

  context 'normally' do
    before(:all) { Fontcustom::Generator.start([input_dir, '-o', output_dir]) }
    after(:all) { cleanup(output_dir) }

    it 'should create webfonts' do
      exts = %w( .woff .eot .ttf .svg )
      files = Dir[output_dir + '/*']
      files.map! { |file| File.extname(file) }

      exts.each { |ext| files.should include(ext) }
    end

    it 'should print font-face declarations in fontcustom.css' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      files = Dir[output_dir + '/*.{woff,eot,ttf,svg}']

      files.each do |file|
        stylesheet.should include(File.basename(file))
      end
    end

    it 'should print icon-* CSS classes in fontcustom.css' do
      stylesheet = File.read(output_dir + '/fontcustom.css')
      icon_names = Dir[input_dir + '/*'].map { |file| File.basename(file)[0..-5].gsub(/\W/, '-').downcase }

      icon_names.each do |name|
        stylesheet.should include('.icon-' + name)
      end
    end
  end

  context 'when input_dir does not exist' do
    let(:fake_input_dir) { 'does/not/exist' }

    it 'should raise an error' do
      results = capture(:stderr) { Fontcustom::Generator.start([fake_input_dir, '-o', output_dir]) }
      results.should =~ /doesn't exist or isn't a directory/
    end
  end

  context 'when input_dir does not contain vectors' do
    let(:empty_input_dir) { 'spec/fixtures/empty' }

    it 'should raise an error' do
      results = capture(:stderr) { Fontcustom::Generator.start([empty_input_dir, output_dir]) }
      results.should =~ /doesn't contain any vectors/
    end
  end

  context 'when flags are passed' do
    it 'should save output files with a custom name' do
      Fontcustom::Generator.start([input_dir, '-o', output_dir, '-n', 'customname'])

      file = Dir[File.join(output_dir, 'customname-*.ttf')].first
      File.exists?(file).should be_true

      cleanup(output_dir)
    end

    it 'should exclude the filename hash' do
      Fontcustom::Generator.start([input_dir, '-o', output_dir, '--nohash'])

      file = File.join(output_dir, 'fontcustom.ttf')
      File.exists?(file).should be_true

      cleanup(output_dir)
    end
  end
end
