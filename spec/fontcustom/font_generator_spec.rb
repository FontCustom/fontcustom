require 'spec_helper'

describe Fontcustom::FontGenerator do
  let(:input_dir) { 'spec/fixtures/vectors' }
  let(:output_dir) { 'tmp' }

  context 'normally' do
    before(:all) { Fontcustom::FontGenerator.start([input_dir, output_dir]) }
    after(:all) { cleanup(output_dir) }

    it 'should create webfonts' do
      exts = %w( .woff .eot .ttf .svg )
      files = Dir[output_dir + '/*']
      files.map! { |file| File.extname(file) }

      exts.each { |ext| files.should include(ext) }
    end
  end

  context 'when input_dir does not exist' do
    let(:fake_input_dir) { 'does/not/exist' }

    it 'should raise an error' do
      results = capture(:stderr) { Fontcustom::FontGenerator.start([fake_input_dir, output_dir]) }
      results.should =~ /doesn't exist or isn't a directory/
    end
  end

  context 'when input_dir does not contain vectors' do
    let(:empty_input_dir) { 'spec/fixtures/empty' }

    it 'should raise an error' do
      results = capture(:stderr) { Fontcustom::FontGenerator.start([empty_input_dir, output_dir]) }
      results.should =~ /doesn't contain any vectors/
    end
  end
end
