require 'spec_helper'

describe Fontcustom::Util do
  def util
    Fontcustom::Util
  end

  context ".check_fontforge" do
    it "should raise error if fontforge isn't installed" do
      util.stub(:"`").and_return("")
      expect { util.check_fontforge }.to raise_error Fontcustom::Error, /install fontforge/
    end
  end

  context ".collect_options" do
    it "should return defaults when called without arguments" do
      options = util.collect_options
      defaults = util::DEFAULT_OPTIONS.dup

      # ignore :templates and :output since they're generated
      options.delete(:templates)
      defaults.delete(:templates)
      options.delete(:output)
      defaults.delete(:output)

      options.should == defaults
    end

    it "should overwrite defaults with config file" do
      options = util.collect_options :config => fixture("fontcustom.yml")
      options[:file_name].should == "custom-name-from-config"
    end

    it "should overwrite config file and defaults with CLI options" do
      options = util.collect_options :config => fixture("fontcustom.yml"), :file_name => "custom-name-from-cli"
      options[:file_name].should == "custom-name-from-cli"
    end

    it "should normalize file name" do
      options = util.collect_options :file_name => " A_stR4nG3 nAm3  "
      options[:file_name].should == "a_str4ng3-nam3"
    end
  end

  context ".get_template_paths" do
    it "should expand template paths" do
      lib = util.gem_lib_path
      templates = util.get_template_paths [:css, :scss, :demo, fixture("not-a-dir")]
      templates.should == [
        File.join(lib, "templates", "fontcustom.css"), 
        File.join(lib, "templates", "_fontcustom.scss"),
        File.join(lib, "templates", "fontcustom.html"),
        fixture("not-a-dir")
      ]
    end

    it "should raise an error if template does not exist" do
      expect { util.get_template_paths [:css, fixture("fake-template")] }.to raise_error(
        Fontcustom::Error, /couldn't find.+#{fixture("fake-template")}/
      )
    end
  end
end
