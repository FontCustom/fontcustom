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

  context ".save_output_data" do
    it "should save icon names to options" do
      options = Fontcustom::Options.new(:input_dir => fixture('vectors'), :output_dir => fixture('mixed-output'))
      generator = Fontcustom::Generator::Font.new options
      generator.stub :update_data_file
      generator.send :save_output_data
      options.icon_names.should =~ ['c', 'd', 'a_r3ally-exotic-f1le-name']
    end

    it "should save font hash to options" do
      options = Fontcustom::Options.new(:input_dir => fixture('vectors'), :output_dir => fixture('mixed-output'))
      generator = Fontcustom::Generator::Font.new options
      generator.stub :update_data_file
      generator.send :save_output_data
      options.font_hash.should be_a(String)
    end

    it "should add generated files to .fontcustom-data" do
      options = Fontcustom::Options.new(:input_dir => fixture('vectors'), :output_dir => fixture('mixed-output'))
      generator = Fontcustom::Generator::Font.new options
      generator.stub :update_data_file
      generator.should_receive(:update_data_file).once.with(/#{options.font_hash}/)
      generator.send :save_output_data
    end
  end

  context ".show_paths" do
    it "should print generated file paths" do
      options = Fontcustom::Options.new(:input_dir => fixture('vectors'), :output_dir => fixture('mixed-output'))
      generator = Fontcustom::Generator::Font.new options
      generator.stub :update_data_file
      generator.send :save_output_data
      stdout = capture(:stdout) { generator.send(:show_paths) }
      puts stdout
      stdout.should =~ /create.+\.(woff|ttf|eot|svg)/
    end
  end
end
