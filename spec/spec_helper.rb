require 'rspec'
require 'json'
require File.expand_path('../../lib/fontcustom.rb', __FILE__)

RSpec.configure do |c|
  def fixture(path)
    File.join(File.expand_path('../fixtures', __FILE__), path)
  end

  def data_file_contents
    {
      :fonts => %w|
        fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.woff
        fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.ttf
        fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.eot
        fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e.svg
      |,
      :templates => %w|fontcustom.css|,
      :file_name => "fontcustom_cc5ce52f2ae4f9ce2e7ee8131bbfee1e", 
      :glyphs => %w|a_r3ally-exotic-f1le-name c d|
    }
  end

  def fontforge_stdout
    "#{data_file_contents.to_json}"
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
end
