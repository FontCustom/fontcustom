require "spec_helper"

describe Fontcustom::Generator::Font do
  subject do 
    base = Fontcustom::Base.new.load :input_dir => fixture("vectors"), :output_dir => fixture("mixed-output")
    Fontcustom::Generator::Font.new base
  end

  context "#initialize" do
    it "should raise error if not passed a Fontcustom::Base instance" do
      expect { Fontcustom::Generator::Font.new }.to raise_error(ArgumentError)
      expect { subject }.to_not raise_error(ArgumentError)
    end
  end

  context "#start" do
    it "should call fontforge" do
      subject.base.stub :verify_all
      subject.stub :run_script 
      subject.stub :save_output_data
      subject.stub :show_paths
      subject.should_receive(:run_script).once.with(/fontforge/)
      subject.start
    end

    it "should not swallow fontforge output if debug option is given" do
      base = Fontcustom::Base.new.load(:input_dir => fixture("vectors"), :output_dir => fixture("output-test"), :debug => true)
      debug = Fontcustom::Generator::Font.new(base)
      debug.base.stub :verify_all
      debug.stub :run_script 
      debug.stub :save_output_data
      debug.stub :show_paths
      debug.should_receive(:run_script).once.with(/^(.(?!\/dev\/null))+$/)
      debug.start
    end
  end

  context "#save_output_data" do
    it "should save icon_names and generated_name to options" do
      subject.base.stub :update_data_file
      subject.send :save_output_data
      subject.base.data[:icon_names].should =~ ["c", "d", "a_r3ally-exotic-f1le-name"]
      subject.base.data[:generated_name].should =~ /#{subject.opts.font_name}-.+/
    end

    it "should add generated files to .fontcustom-data" do
      subject.base.stub(:update_data_file)
      subject.base.should_receive(:update_data_file).once do |files|
        files.each { |file| file.should =~ /fontcustom-.+\.(woff|ttf|eot|svg)/ }
      end
      subject.send :save_output_data # populates icon_names and then calls update_data_file
    end
  end

  context "#show_paths" do
    it "should print generated file paths" do
      subject.stub :update_data_file
      subject.send :save_output_data
      stdout = capture(:stdout) { subject.send(:show_paths) }
      stdout.should =~ /create.+\.(woff|ttf|eot|svg)/
    end
  end
end
