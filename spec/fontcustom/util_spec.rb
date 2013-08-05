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
      [:font_name, :input, :output, :config, :templates].each do |key|
        options.delete key
        defaults.delete key
      end
      options.should == defaults
    end

    it "should raise error if fontcustom.yml isn't valid" do
      args = { :config => fixture("fontcustom-malformed.yml") }
      expect { util.collect_options(args) }.to raise_error Fontcustom::Error, /couldn't read your configuration/
    end

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

    it "should print out which fontcustom.yml it's using"
    it "should print a warning if fontcustom.yml wasn't specified / doesn't exist"
  end

  context ".get_input_paths" do
    context "when passed a hash" do
      it "should return a hash of input locations" do
        options = {
          :input => { :vectors => "vectors" },
          :project_root => fixture
        }
        paths = util.get_input_paths(options)
        paths.should have_key("vectors")
        paths.should have_key("templates")
      end

      it "should set :templates as :vectors if :templates isn't passed" do
        options = {
          :input => { :vectors => "vectors" },
          :project_root => fixture
        }
        paths = util.get_input_paths(options)
        paths[:vectors].should equal(paths[:templates])
      end

      it "should preserve :templates if it is passed" do
        options = {
          :input => { :vectors => "vectors", :templates => "templates" },
          :project_root => fixture
        }
        paths = util.get_input_paths(options)
        paths[:templates].should_not equal(paths[:vectors])
      end

      it "should raise an error if :vectors isn't included" do
        options = {
          :input => { :templates => "templates" },
          :project_root => fixture
        }
        expect { util.get_input_paths(options) }.to raise_error Fontcustom::Error, /should be a string or a hash/
      end

      it "should raise an error if :vectors doesn't point to an existing directory" do
        options = {
          :input => { :vectors => "not-a-dir" },
          :project_root => fixture
        }
        expect { util.get_input_paths(options) }.to raise_error Fontcustom::Error, /should be a directory/
      end
    end

    context "when passed a string" do
      it "should return a hash of input locations" do
        options = { 
          :input => "vectors",
          :project_root => fixture
        }
        paths = util.get_input_paths(options)
        paths.should have_key("vectors")
        paths.should have_key("templates")
      end

      it "should set :templates to match :vectors" do
        options = { 
          :input => "vectors",
          :project_root => fixture
        }
        paths = util.get_input_paths(options)
        paths[:vectors].should equal(paths[:templates])
      end

      it "should raise an error if :vectors doesn't point to a directory" do
        options = { 
          :input => "not-a-dir",
          :project_root => fixture
        }
        expect { util.collect_options options }.to raise_error Fontcustom::Error, /should be a directory/
      end
    end
  end

  context ".get_output_paths" do
    it "should default to :project_root/:font_name if no output is specified" do
      options = { :project_root => fixture, :font_name => "test" }
      paths = util.get_output_paths(options)
      paths[:fonts].should eq(fixture("test"))
    end

    it "should print a warning when defaulting to :project_root/fonts"

    context "when passed a hash" do
      it "should return a hash of output locations" do 
        options = {
          :output => { :fonts => "fonts" },
          :project_root => fixture
        }
        paths = util.get_output_paths(options)
        paths.should have_key("fonts")
        paths.should have_key("css")
        paths.should have_key("preview")
      end

      it "should set :css and :preview to match :fonts if either aren't passed" do
        options = {
          :output => { :fonts => "fonts" },
          :project_root => fixture
        }
        paths = util.get_output_paths(options)
        paths[:css].should equal(paths[:fonts])
        paths[:preview].should equal(paths[:fonts])
      end

      it "should preserve :css and :preview if they do exist" do
        options = {
          :output => { 
            :fonts => "fonts",
            :css => "styles",
            :preview => "preview"
          },
          :project_root => fixture
        }
        paths = util.get_output_paths(options)
        paths[:css].should_not equal(paths[:fonts])
        paths[:preview].should_not equal(paths[:fonts])
      end
      
      it "should raise an error if :fonts isn't included" do
        options = {
          :output => { :css => "styles" },
          :project_root => fixture
        }
        expect { util.get_output_paths(options) }.to raise_error Fontcustom::Error, /containing a "fonts" key/
      end
    end

    context "when passed a string" do
      it "should return a hash of output locations" do
        options = {
          :output => "fonts",
          :project_root => fixture
        }
        paths = util.get_output_paths(options)
        paths.should have_key("fonts")
        paths.should have_key("css")
        paths.should have_key("preview")
      end

      it "should set :css and :preview to match :fonts" do
        options = {
          :output => "fonts",
          :project_root => fixture
        }
        paths = util.get_output_paths(options)
        paths[:css].should equal(paths[:fonts])
        paths[:preview].should equal(paths[:fonts])
      end

      it "should raise an error if :fonts exists but isn't a directory" do
        options = {
          :output => "not-a-dir",
          :project_root => fixture
        }
        expect { util.get_output_paths(options) }.to raise_error Fontcustom::Error, /directory, not a file/
      end
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

    it "should find custom templates in :template_path" do
      options = { 
        :project_root => fixture, 
        :input => { :templates => "templates" },
        :templates => %W|custom.css|
      }
      templates = util.get_templates options
      templates.should eq([ fixture("templates/custom.css") ])
    end

    it "should raise an error if a template does not exist" do
      options = {
        :project_root => fixture,
        :input => { :templates => "templates" },
        :templates => %W|css fake-template|
      }
      expect { util.get_templates options }.to raise_error Fontcustom::Error, /couldn't find.+fake-template/
    end
  end
end
