require "rspec"
require "json"
require "fileutils"
require File.expand_path("../../lib/fontcustom.rb", __FILE__)

RSpec.configure do |c|
  def fixture(path = "")
    File.join(File.expand_path("../fixtures", __FILE__), path)
  end

  # TODO use real values after refactor is complete
  def manifest_contents(root = Dir.pwd)
    {
      :checksum => "82a59e769bc60192484f2620570bbb59e225db97c1aac3f242a2e49d6060a19c",
      :fonts => [
        "#{root}/fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.ttf",
        "#{root}/fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.svg",
        "#{root}/fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.woff",
        "#{root}/fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.eot"
      ],
      :glyphs => {
        :"a_r3ally-exotic-f1le-name" => {
          :codepoint => 61696,
          :source => "#{root}/vectors/a_R3ally-eXotic f1Le Name.svg"
        },
        :c => {
          :codepoint => 61697,
          :source => "#{root}/vectors/C.svg"
        },  
        :d => {
          :codepoint => 61698,
          :source => "#{root}/vectors/D.svg"}
        },
      :options => {
        :autowidth => false,
        :config => false,
        :css_prefix => "icon-",
        :debug => false,
        :font_name => "fontcustom",
        :input => {
          :templates => "#{root}/vectors",
          :vectors => "#{root}/vectors"
        },
        :manifest => "#{root}/.fontcustom-manifest.json",
        :no_hash => false,
        :output => {
          :css => "#{root}/fontcustom",
          :fonts => "#{root}/fontcustom",
          :preview => "#{root}/fontcustom"
        },
        :preprocessor_path => nil,
        :project_root => "#{root}",
        :quiet => true,
        :templates => [
          "#{Fontcustom.gem_lib}/templates/fontcustom.css",
          "#{Fontcustom.gem_lib}/templates/fontcustom-preview.html"
        ]
      },
      :templates => []
    }
  end

  def fontforge_stderr
    "Copyright (c) 2000-2012 by George Williams.\n Executable based on sources from 14:57 GMT 31-Jul-2012-D.\n Library based on sources from 14:57 GMT 31-Jul-2012.\n"
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end

  def live_test(cleanup = true)
    testdir = fixture File.join("sandbox", "test")
    begin
      FileUtils.mkdir testdir
      FileUtils.cp_r fixture("shared/vectors"), testdir
      FileUtils.cd testdir do
        yield(testdir)
      end
    ensure
      FileUtils.rm_r testdir if cleanup
    end
  end

  def test_manifest(options = {:input => fixture("shared/vectors"), :quiet => true})
    base = Fontcustom::Base.new options
    manifest = base.instance_variable_get :@manifest
    manifest[:checksum] = base.send :checksum
    base.save_manifest
    base.instance_variable_get(:@options)[:manifest]
  end
end
