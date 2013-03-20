require 'spec_helper'

describe Fontcustom::Generator::Font do
  subject do
    options = Fontcustom::Options.new
    Fontcustom::Generator::Font.new(options)
  end

  it 'should raise error if not passed options' do
    expect { Fontcustom::Generator::Font.new }.to raise_error(ArgumentError)
  end

  context '#generate' do
    before(:each) do
      subject.stub :cleanup_old_files
      subject.stub :run_script 
      subject.stub :show_paths
    end

    it 'should call fontforge' do
      subject.should_receive(:run_script).once.with(/fontforge/)
      subject.generate
    end

    it 'should return an ouput hash'
  end

  context '.cleanup_old_files' do
    it 'should delete old files from cache'
  end

  context '.show_paths' do
    it 'should print generated file paths' do
      subject.send(:show_paths)
    end
  end
end
