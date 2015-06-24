require 'rspec'
require 'json'
require 'fileutils'
require File.expand_path('../../lib/fontcustom.rb', __FILE__)

RSpec.configure do |c|
  c.before(:all) do
    FileUtils.cd fixture
    puts "Running `cd #{Dir.pwd}`"
  end

  def fixture(path = '')
    File.join(File.expand_path('../fixtures', __FILE__), path)
  end

  def manifest_contents
    {
      checksum: {
        current: '82a59e769bc60192484f2620570bbb59e225db97c1aac3f242a2e49d6060a19c',
        previous: '82a59e769bc60192484f2620570bbb59e225db97c1aac3f242a2e49d6060a19c'
      },
      fonts: [
        'fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.ttf',
        'fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.svg',
        'fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.woff',
        'fontcustom/fontcustom_82a59e769bc60192484f2620570bbb59.eot'
      ],
      glyphs: {
        :"a_r3ally-exotic-f1le-name" => {
          codepoint: 61696,
          source: 'vectors/a_R3ally-eXotic f1Le Name.svg'
        },
        :c => {
          codepoint: 61697,
          source: 'vectors/C.svg'
        },
        :d => {
          codepoint: 61698,
          source: 'vectors/D.svg' }
      },
      options: {
        autowidth: false,
        config: false,
        css_selector: '.icon-{{glyph}}',
        debug: false,
        font_name: 'fontcustom',
        force: true,
        input: {
          templates: 'vectors',
          vectors: 'vectors'
        },
        no_hash: false,
        output: {
          css: 'fontcustom',
          fonts: 'fontcustom',
          preview: 'fontcustom'
        },
        preprocessor_path: nil,
        quiet: true,
        templates: %w(css scss preview)
      },
      templates: []
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

  def live_test
    testdir = fixture File.join('sandbox', 'test')
    FileUtils.rm_r testdir if File.directory?(testdir)
    FileUtils.mkdir testdir
    FileUtils.cp_r fixture('shared/vectors'), testdir
    FileUtils.cd testdir do
      yield(testdir)
    end
  end

  def test_manifest(options = { input: 'vectors', quiet: true })
    base = Fontcustom::Base.new options
    manifest = base.instance_variable_get :@manifest
    checksum = base.send :checksum
    manifest.set :checksum, current: checksum, previous: ''
    manifest
  end
end
