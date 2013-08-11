require "spec_helper"

describe Fontcustom::Generator::Font do
  def generator(options)
    opts = Fontcustom::Util.collect_options options
    Fontcustom::Generator::Font.new([opts])
  end

  context "#prepare_output_dirs" do
    it "should create output dir if it doesn't exist" do
      options = {
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "create-me"
      }
      gen = generator options
      gen.stub(:empty_directory)
      gen.should_receive(:empty_directory).with(fixture("create-me"), anything)
      gen.prepare_output_dirs
    end

    it "should create dirs for multiple output dirs" do
      options = {
        :project_root => fixture,
        :input => "shared/vectors",
        :output => {
          :fonts => "assets/fonts",
          :css => "assets/stylesheets"
        }
      }
      gen = generator options
      gen.stub(:empty_directory)
      gen.should_receive(:empty_directory).twice
      gen.prepare_output_dirs
    end
  end

  context "#get_data" do
    it "should assign empty data model if data file is empty or missing" do
      options = {
        :project_root => fixture,
        :input => "shared/vectors"
      }
      gen = generator options
      gen.get_data
      data = gen.instance_variable_get("@data")
      data.should == Fontcustom::DATA_MODEL
    end

    it "should assign @data from data file" do
      options = {
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output"
      }
      gen = generator options
      gen.get_data
      data = gen.instance_variable_get("@data")
      data[:fonts] =~ data_file_contents[:fonts]
    end
  end

  context "#reset_output" do
    subject do
      options = {
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output"
      }
      gen = generator options
      gen.stub :remove_file
      gen.stub :append_to_file
      Fontcustom::Util.stub :clear_file
      gen.instance_variable_set(:@data, data_file_contents)
      gen
    end

    it "should delete fonts from @data[:fonts]" do
      subject.should_receive(:remove_file).exactly(4).times.with(/fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e/, :verbose => true)
      subject.reset_output
    end

    it "should not delete non-font files" do
      subject.should_not_receive(:remove_file).with("dont-delete-me.bro")
      subject.should_not_receive(:remove_file).with("another-font.ttf")
      subject.should_not_receive(:remove_file).with("fontcustom.css")
      subject.reset_output
    end

    it "should empty @data[:fonts]" do
      subject.reset_output
      subject.instance_variable_get(:@data)[:fonts].should be_empty
    end

    it "should update the data file" do
      file = fixture(".fontcustom-data")
      Fontcustom::Util.should_receive(:clear_file).once.with(file)
      subject.should_receive(:append_to_file).once.with(file, /"fonts":/, :verbose => false)
      subject.reset_output
    end

    it "should be silent" do
      stdout = capture(:stdout) { subject.reset_output }
      stdout.should == ""
    end
  end

  context "#generate" do
    subject do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output"
      )
      gen.stub(:"`").and_return fontforge_output
      gen
    end

    it "should call fontforge" do
      subject.should_receive(:"`").with(/fontforge -script/)
      subject.generate
    end

    it "should pass options to fontforge" do
      subject.should_receive(:"`").with(/#{fixture("shared/vectors")}.+#{fixture("mixed-output")}/)
      subject.generate
    end

    it "should assign @json" do
      subject.generate
      json = subject.instance_variable_get(:@json)
      json.should == data_file_contents.to_json
    end

    it "should raise error if fontforge fails" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "fake-dir-should-cause-failure",
        :debug => true
      )
      expect { capture(:stdout) { gen.generate } }.to raise_error Fontcustom::Error, /failed unexpectedly/
    end
  end

  context "#collect_data" do
    it "should assign @data from @json" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output"
      )
      gen.instance_variable_set(:@data, Fontcustom::DATA_MODEL)
      gen.instance_variable_set(:@json, data_file_contents.to_json)
      gen.collect_data
      data = gen.instance_variable_get(:@data)
      data[:glyphs].should =~ ["c", "d", "a_r3ally-exotic-f1le-name"]
      data[:file_name].should == "fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e"
      data[:fonts].should =~ [
        "fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.eot",
        "fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.svg",
        "fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.ttf",
        "fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.woff"
      ]
    end
  end

  context "#announce_files" do
    it "should print generated files to console" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output"
      )
      gen.instance_variable_set :@data, data_file_contents
      stdout = capture(:stdout) { gen.announce_files }
      stdout.should =~ /create.+\.(woff|ttf|eot|svg)/
    end

    it "should print nothing if verbose is false" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output",
        :verbose => false
      )
      gen.instance_variable_set :@data, data_file_contents
      stdout = capture(:stdout) { gen.announce_files }
      stdout.should == ""
    end
  end

  context "#save_data" do
    it "should update data file (TEMP)" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output"
      )
      Fontcustom::Util.stub :clear_file
      gen.stub :append_to_file
      gen.instance_variable_set(:@data, data_file_contents)
      file = File.join fixture(".fontcustom-data")
      Fontcustom::Util.should_receive(:clear_file).once.with(file)
      gen.should_receive(:append_to_file).once.with do |path, content|
        path.should == file
        content.should match(/"fonts":/)
        content.should match(/"glyphs":/)
        content.should match(/"file_name":/)
      end
      gen.save_data
    end

    it "should be silent if verbose is false" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "mixed-output",
        :verbose => false
      )
      Fontcustom::Util.stub :clear_file
      gen.stub :append_to_file
      gen.instance_variable_set(:@data, data_file_contents)
      stdout = capture(:stdout) { gen.save_data }
      stdout.should == ""
    end
  end
end
