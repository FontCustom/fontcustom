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
      # ignore generated options
      [:input, :output, :config, :templates].each do |key|
        options.delete key
        defaults.delete key
      end
      options.should == defaults
    end

    it "should raise error if fontcustom.yml isn't valid"
    it "should announce when fontcustom.yml is being used"

    it "should overwrite defaults with config file" do
      options = util.collect_options :config => fixture("fontcustom.yml")
      options[:font_name].should == "Custom-Name-From-Config"
    end

    it "should overwrite config file and defaults with CLI options" do
      options = util.collect_options :config => fixture("fontcustom.yml"), :font_name => "custom-name-from-cli"
      options[:font_name].should == "custom-name-from-cli"
    end

    it "should normalize file name" do
      options = util.collect_options :font_name => " A_stR4nG3  nAm3 Ø&  "
      options[:font_name].should == "A_stR4nG3--nAm3---"
    end
  end

  context ".get_config_path" do
    it "should search for fontcustom.yml if options[:config] is a dir" do
      options = { :config => fixture("") }
      util.get_config_path(options).should == fixture("fontcustom.yml")
    end

    it "should search use options[:config] if it's a file" do
      options = { :config => fixture("fontcustom.yml") }
      util.get_config_path(options).should == fixture("fontcustom.yml")
    end

    it "should search in project_root if no options[:config] is given" do
      options = { :project_root => fixture("") }
      util.get_config_path(options).should == fixture("fontcustom.yml")
    end

    it "should raise error if fontcustom.yml was specified but doesn't exist" do
      options = { :config => fixture("vectors") }
      expect { util.get_config_path(options) }.to raise_error Fontcustom::Error, /couldn't find/
    end

    it "should print out which fontcustom.yml it found"
    it "should print a warning if fontcustom.yml wasn't specified / doesn't exist"
  end

  context ".get_input_paths" do
    context "when passed a string" do
      it "should return a hash of input locations"
      it "should set :templates to match :vectors"
      it "should raise an error if :vectors doesn't point to a directory"
    end

    context "when passed a hash" do
      it "should return a hash of input locations"
      it "should set :templates as :vectors if :templates isn't passed"
      it "should preserve :templates if it is passed"
      it "should raise an error if :vectors isn't included"
      it "should raise an error if :vectors doesn't point to an existing directory"
    end
  end

  context ".get_output_paths" do
    context "when passed a string" do
      it "should return a hash of output locations"
      it "should set :css and :preview to match :fonts"
      it "should default to :project_root/fonts if no output is specified" 
      it "should print a warning when defaulting to :project_root/fonts"
      it "should raise an error if :fonts exists but isn't a directory"
    end

    context "when passed a hash" do
      it "should return a hash of output locations"
      it "should set :css and :preview to match :fonts if either aren't passed"
      it "should preserve :css and :preview if they do exist"
      it "should raise an error if :fonts isn't included"
    end
  end

  context ".get_templates" do
    it "should ensure that 'css' is included with 'preview'" do
      lib = util.gem_lib_path
      options = { :input => fixture("vectors"), :templates => %W|preview| }
      templates = util.get_templates options
      templates.should =~ [
        File.join(lib, "templates", "fontcustom.css"), 
        File.join(lib, "templates", "fontcustom-preview.html")
      ]
    end

    it "should expand shorthand for packaged templates" do
      lib = util.gem_lib_path
      options = { :input => fixture("vectors"), :templates => %W|preview css scss bootstrap bootstrap-scss bootstrap-ie7 bootstrap-ie7-scss| }
      templates = util.get_templates options
      templates.should =~ [
        File.join(lib, "templates", "fontcustom-preview.html"),
        File.join(lib, "templates", "fontcustom.css"), 
        File.join(lib, "templates", "_fontcustom.scss"),
        File.join(lib, "templates", "fontcustom-bootstrap.css"), 
        File.join(lib, "templates", "_fontcustom-bootstrap.scss"), 
        File.join(lib, "templates", "fontcustom-bootstrap-ie7.css"), 
        File.join(lib, "templates", "_fontcustom-bootstrap-ie7.scss") 
      ]
    end

    it "> should look in template_path first"
    it "> should look in project_path second"

    it "should search in Dir.pwd first" do
      pending
      Dir.chdir fixture("")
      options = { :templates => %W|not-a-dir| }
      templates = util.get_templates options
      templates.should =~ ["not-a-dir"]
    end

    it "should search in options[:input] second" do
      pending
      options = { :input => fixture("empty"), :templates => %W|no_vectors_here.txt| }
      templates = util.get_templates options
      templates.should =~ [fixture("empty/no_vectors_here.txt")]
    end

    it "should raise an error if a template does not exist" do
      options = { 
        :input => { :vectors => fixture("vectors"), :templates => fixture("vectors") },
        :templates => %W|css fake-template| 
      }
      expect { util.get_templates options }.to raise_error(
        Fontcustom::Error, /couldn't find.+fake-template/
      )
    end
  end
end
