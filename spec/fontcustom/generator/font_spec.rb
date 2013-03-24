require "spec_helper"

describe Fontcustom::Generator::Font do
  subject do
    options = Fontcustom::Options.new
    Fontcustom::Generator::Font.new(options)
  end

  context "#initialize" do
    it "should raise error if not passed options" do
      expect { Fontcustom::Generator::Font.new }.to raise_error(ArgumentError)
    end
  end

  context "#start" do
    it "should call fontforge" do
      subject.stub :run_script 
      subject.stub :save_output_data
      subject.stub :show_paths
      subject.should_receive(:run_script).once.with(/fontforge/)
      subject.start
    end

    it "should not swallow fontforge output if debug option is given" do
      options = Fontcustom::Options.new(:debug => true)
      debug = Fontcustom::Generator::Font.new(options)
      debug.stub :run_script 
      debug.stub :save_output_data
      debug.stub :show_paths
      debug.should_receive(:run_script).once.with(/^(.(?!\/dev\/null))+$/)
      debug.start
    end
  end

  context ".save_output_data" do
    it "should save icon_names and font_hash to options" do
      options = Fontcustom::Options.new(:input_dir => fixture("vectors"), :output_dir => fixture("mixed-output"))
      generator = Fontcustom::Generator::Font.new options
      generator.stub :update_data_file
      generator.send :save_output_data
      options.icon_names.should =~ ["c", "d", "a_r3ally-exotic-f1le-name"]
      options.font_hash.should be_a(String)
    end

    it "should add generated files to .fontcustom-data" do
      options = Fontcustom::Options.new(:input_dir => fixture("vectors"), :output_dir => fixture("mixed-output"))
      generator = Fontcustom::Generator::Font.new options
      Fontcustom.stub(:update_data_file)
      Fontcustom.should_receive(:update_data_file).once do |path, arr|
        path.should == options.output_dir
        arr.each { |item| item.should =~ /fontcustom-.+\.(woff|ttf|eot|svg)/ }
      end
      generator.send :save_output_data # populates icon_names and then calls update_data_file
    end
  end

  context ".show_paths" do
    it "should print generated file paths" do
      options = Fontcustom::Options.new(:input_dir => fixture("vectors"), :output_dir => fixture("mixed-output"))
      generator = Fontcustom::Generator::Font.new options
      generator.stub :update_data_file
      generator.send :save_output_data
      stdout = capture(:stdout) { generator.send(:show_paths) }
      stdout.should =~ /create.+\.(woff|ttf|eot|svg)/
    end
  end
end
