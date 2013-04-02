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
      defaults = Fontcustom::DEFAULT_OPTIONS.dup

      # ignore :templates and :output since they're generated
      options.delete(:templates)
      defaults.delete(:templates)
      options.delete(:output)
      defaults.delete(:output)

      options.should == defaults
    end

    it "should overwrite defaults with config file" do
      options = util.collect_options :config => fixture("fontcustom.yml")
      options[:font_name].should == "custom-name-from-config"
    end

    it "should overwrite config file and defaults with CLI options" do
      options = util.collect_options :config => fixture("fontcustom.yml"), :font_name => "custom-name-from-cli"
      options[:font_name].should == "custom-name-from-cli"
    end

    it "should normalize file name" do
      options = util.collect_options :font_name => " A_stR4nG3 nAm3  "
      options[:font_name].should == "a_str4ng3-nam3"
    end
  end

  context ".get_config_path" do
    it "should search options[:config] first"
    it "should search input dir second"
    it "should return false if neither exist"
  end

  context ".get_template_paths" do
    it "should expand shorthand for packaged templates" do
      lib = util.gem_lib_path
      options = { :input => fixture("vectors"), :templates => %W|css scss preview| }
      templates = util.get_template_paths options
      templates.should == [
        File.join(lib, "templates", "fontcustom.css"), 
        File.join(lib, "templates", "_fontcustom.scss"),
        File.join(lib, "templates", "fontcustom.html")
      ]
    end

    it "should search in Dir.pwd first"
    it "should search in options[:input] second"

    it "should raise an error if a template does not exist" do
      options = { :input => fixture("vectors"), :templates => %W|css #{fixture("fake-template")}| }
      expect { util.get_template_paths options }.to raise_error(
        Fontcustom::Error, /couldn't find.+#{fixture("fake-template")}/
      )
    end
  end
end
