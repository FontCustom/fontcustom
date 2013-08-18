require "spec_helper"

describe Fontcustom::Generator::Template do
  def generator(options)
    opts = Fontcustom::Util.collect_options options
    Fontcustom::Generator::Template.new([opts])
  end

  context "#get_data" do
    it "should raise error if data file doesn't exist" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors"
      )
      expect { gen.get_data }.to raise_error Fontcustom::Error, /\.fontcustom-data is required/
    end

    # TODO ensure data file is correct
    it "should assign @data from data file" do
      gen = generator(
        :project_root => fixture("generators"),
        :input => "../shared/vectors"
      )
      gen.get_data
      gen.instance_variable_get(:@data)[:templates].should =~ data_file_contents[:templates]
    end
  end

  context "#reset_output" do
    subject do
      gen = generator(
        :project_root => fixture("generators"),
        :input => "../shared/vectors",
        :output => "mixed-output",
        :verbose => false
      )
      gen.stub :remove_file
      gen.stub :overwrite_file
      gen.instance_variable_set(:@data, data_file_contents)
      gen
    end

    it "should delete files from @data[:templates]" do
      subject.should_receive(:remove_file).once.with(/fontcustom\.css/, anything)
      subject.reset_output
    end

    it "should not delete non-template files" do
      subject.should_not_receive(:remove_file).with("dont-delete-me.bro")
      subject.should_not_receive(:remove_file).with("another-font.ttf")
      subject.should_not_receive(:remove_file).with(/fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e/)
      subject.reset_output
    end

    it "should empty @data[:fonts]" do
      subject.reset_output
      subject.instance_variable_get(:@data)[:templates].should be_empty
    end

    it "should update the data file" do
      file = fixture("generators/.fontcustom-data")
      subject.should_receive(:overwrite_file).once.with(file, /"templates":/)
      subject.reset_output
    end

    it "should be silent" do
      stdout = capture(:stdout) { subject.reset_output }
      stdout.should == ""
    end
  end

  context "#make_relative_paths" do
    it "should assign :css_to_fonts and :preview_to_css" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => {:fonts => "foo/fonts", :css => "output/css", :preview => ""}
      )
      gen.instance_variable_set "@data", data_file_contents
      gen.make_relative_paths
      data = gen.instance_variable_get("@data")
      data[:paths][:css_to_fonts].should match("../../foo/fonts")
      data[:paths][:preview_to_css].should match("output/css/")
      data[:paths][:preprocessor_to_fonts].should eq(data[:paths][:css_to_fonts])
    end

    it "should assign :preprocessor_to_css if :preprocessor_font_path is set" do
      gen = generator(
        :project_root => fixture,
        :preprocessor_font_path => "fonts/fontcustom",
        :input => "shared/vectors",
        :output => {:fonts => "foo/bar/fonts", :css => "output/css", :preview => ""}
      )
      gen.instance_variable_set "@data", data_file_contents
      gen.make_relative_paths
      data = gen.instance_variable_get("@data")
      data[:paths][:preprocessor_to_fonts].should match("fonts/fontcustom")
    end

    it "should assign '.' when paths are the same" do
      gen = generator(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "output"
      )
      gen.instance_variable_set "@data", data_file_contents
      gen.make_relative_paths
      data = gen.instance_variable_get("@data")
      data[:paths][:css_to_fonts].should match("./")
      data[:paths][:preview_to_css].should match("./")
    end
  end

  context "#generate" do
    subject do
      gen = generator(
        :project_root => fixture("generators"),
        :input => {:vectors => "../shared/vectors", :templates => "../shared/templates"},
        :output => "mixed-output",
        :templates => %W|scss css custom.css|,
        :verbose => false
      )
      gen.instance_variable_set :@data, data_file_contents
      gen.stub :template
      gen.stub :overwrite_file
      gen
    end

    it "should call #template for each template" do
      subject.should_receive(:template).exactly(3).times do |*args|
        args[1].should match(/(fontcustom\.css|_fontcustom\.scss|custom\.css)/)
      end
      subject.generate
    end

    it "should update data file with generated templates" do
      file = fixture("generators/.fontcustom-data")
      subject.should_receive(:overwrite_file).once.with do |path, content|
        path.should == file
        content.should match(/fontcustom\.css/)
        content.should match(/_fontcustom\.scss/)
        content.should match(/custom\.css/)
      end
      subject.generate
    end

    it "should be silent if verbose is false" do
      stdout = capture(:stdout) { subject.generate }
      stdout.should == ""
    end

    context "when various output locations are given" do
      subject do
        gen = generator(
          :project_root => fixture,
          :input => {:vectors => "shared/vectors", :templates => "shared/templates"},
          :output => {:fonts => "output/fonts", :css => "output/css", :preview => "output/views", "custom.css" => "output/custom"},
          :templates => %W|scss preview css custom.css regular.css|,
          :verbose => false
        )
        gen.instance_variable_set :@data, data_file_contents
        gen.stub :template
        gen.stub :overwrite_file
        gen
      end

      it "should output custom templates to their matching :output paths" do
        subject.should_receive(:template).exactly(5).times do |*args|
          if File.basename(args[0]) == "custom.css"
            args[1].should == fixture("output/custom/custom.css")
          end
        end
        subject.generate
      end

      it "should output css templates into :css" do
        subject.should_receive(:template).exactly(5).times do |*args|
          name = File.basename(args[0])
          if %w|_fontcustom.scss fontcustom.css regular.css|.include? name
            args[1].should match(/output\/css\/#{name}/)
          end
        end
        subject.generate
      end

      it "should output fontcustom-preview.html into :preview" do
        subject.should_receive(:template).exactly(5).times do |*args|
          if File.basename(args[0]) == "fontcustom-preview.html"
            args[1].should == fixture("output/views/fontcustom-preview.html")
          end
        end
        subject.generate
      end
    end
  end
end
