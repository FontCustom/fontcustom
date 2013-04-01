require "spec_helper"
require "fileutils"
require "fontcustom/watcher"

describe Fontcustom::Watcher do
  def watcher(options)
    Fontcustom::Generator::Font.stub :start
    Fontcustom::Generator::Template.stub :start
    opts = Fontcustom::Util.collect_options options
    opts[:blocking] = false # undocumented — non-blocking use of watcher
    Fontcustom::Watcher.new opts
  end

  context "#watch" do
    it "should call generators on init" do
      Fontcustom::Generator::Font.should_receive(:start).once 
      Fontcustom::Generator::Template.should_receive(:start).once
      w = watcher :input => fixture("vectors"), :output => fixture("watcher-test")
      # silence output
      capture(:stdout) do
        w.watch
        w.stop
      end
    end

    it "should call generators when vectors change" do
      Fontcustom::Generator::Font.should_receive(:start).twice
      Fontcustom::Generator::Template.should_receive(:start).twice
      w = watcher :input => fixture("vectors"), :output => fixture("watcher-test")

      capture(:stdout) do
        begin
          w.watch
          FileUtils.cp fixture("vectors/C.svg"), fixture("vectors/test.svg")
        ensure
          w.stop
          new = fixture("vectors/test.svg")
          FileUtils.rm(new) if File.exists?(new)
        end
      end
    end

    it "should do nothing when non-vectors change" do
      Fontcustom::Generator::Font.should_receive(:start).once
      Fontcustom::Generator::Template.should_receive(:start).once
      w = watcher :input => fixture("vectors"), :output => fixture("watcher-test")

      capture(:stdout) do
        begin
          w.watch
          FileUtils.touch fixture("vectors/non-vector-file")
        ensure
          w.stop
          new = fixture("vectors/non-vector-file")
          FileUtils.rm(new) if File.exists?(new)
        end
      end
    end
  end
end
