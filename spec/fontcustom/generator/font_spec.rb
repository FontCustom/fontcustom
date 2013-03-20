require 'spec_helper'

describe Fontcustom::Generator::Font do
  subject do
    options = Fontcustom::Options.new
    Fontcustom::Generator::Font.new(options)
  end

  it 'should raise error if not passed options' do
    expect { Fontcustom::Generator::Font.new }.to raise_error(ArgumentError)
  end

  it 'should clean up old generated files'

  context '#generate' do
    it 'should call fontforge' do
      # don't actually run the script
      subject.stub :run_script
      subject.should_receive(:run_script).once.with(/fontforge/)

      subject.generate
    end

    it 'should print generated file paths'

    it 'should return an ouput hash'
  end
end
