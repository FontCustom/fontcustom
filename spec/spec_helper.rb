require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'fileutils'
require File.expand_path('../../lib/fontcustom.rb', __FILE__)

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

def cleanup(path)
  FileUtils.rm_r path
end
