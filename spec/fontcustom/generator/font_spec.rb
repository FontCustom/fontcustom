require "spec_helper"

describe Fontcustom::Generator::Font do
  subject do
    options = Fontcustom::Options.new
    Fontcustom::Generator::Font.new(options)
  end

  it "should raise error if not passed options" do
    expect { Fontcustom::Generator::Font.new }.to raise_error(ArgumentError)
  end

  context "#start" do
    it "should call fontforge" do
      subject.stub :run_script 
      subject.stub :save_output_data
      subject.stub :show_paths
      subject.should_receive(:run_script).once.with(/fontforge/)
      subject.start
    end
  end

  context "#save_output_data (unstubbed test)" do
    it "should add generated files to .fontcustom-data" do
      pending 'not yet'
      output_dir = fixture('unstubbed-test')
      options = Fontcustom::Options.new(:input_dir => fixture('vectors'), :output_dir => output_dir)
      Fontcustom.verify_output_dir(options.output_dir) # creates dir
      unstubbed = Fontcustom::Generator::Font.new(options)

      stdout = capture(:stdout) { unstubbed.start }
      puts stdout
    end
  end

  context "#show_paths" do
    it "should print generated file paths" do
      stdout = capture(:stdout) { subject.send(:show_paths) }
      stdout.should =~ /create.+\.(woff|ttf|eot|svg)/
    end
  end
end
