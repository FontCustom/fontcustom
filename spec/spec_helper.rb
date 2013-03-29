require 'rspec'
require 'fileutils'
require File.expand_path('../../lib/fontcustom.rb', __FILE__)

RSpec.configure do |c|
  def fixture(path)
    File.join(File.expand_path('../fixtures', __FILE__), path)
  end

  def data_file_contents
    {
      :files => %w|
        fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.eot
        fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.svg
        fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.ttf
        fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e.woff
        fontcustom.css
      |,
      :file_name => "fontcustom-cc5ce52f2ae4f9ce2e7ee8131bbfee1e", 
      :icons => %w|a b c|
    }
  end

  def cleanup(dir)
    FileUtils.rm_r(dir, :verbose => true) if File.exists?(dir)
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
