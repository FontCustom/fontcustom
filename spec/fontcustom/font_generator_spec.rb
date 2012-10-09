require 'spec_helper'
require 'fileutils'

describe Fontcustom::FontGenerator do
  subject { Fontcustom::FontGenerator }

  describe '#generate (default)' do
    before do
      @default_output = 'demo/fontcustom'
      @names = subject.generate('demo/input')
    end

    it 'must create a directory full of webfonts' do
      File.directory?(@default_output).must_equal true
      Dir[@default_output + '/*'].empty?.must_equal false
    end

    it 'must return an array of icon names' do
      @names.wont_be_empty
      @names.wont_be_nil
    end

    after do
      FileUtils.rm_r(@default_output)
    end
  end

  describe '#generate (edgecases)' do
    it 'must allow a different output directory to be set' do
      custom_output = 'demo/custom_output'
      subject.generate('demo/input', custom_output)

      File.directory?(custom_output).must_equal true
      Dir[custom_output + '/*'].empty?.must_equal false

      FileUtils.rm_r(custom_output)
    end

    it 'must complain if input directory does not exit' do
      lambda { subject.generate('does/not/exist') }.must_raise RuntimeError
    end
  end
end
