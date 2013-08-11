require "spec_helper"
require "fileutils"
require "fontcustom/watcher"

describe Fontcustom::Watcher do
  def watcher(options)
    Fontcustom::Generator::Font.stub :start
    Fontcustom::Generator::Template.stub :start
    opts = Fontcustom::Util.collect_options options
    opts[:blocking] = false # undocumented — non-blocking use of watcher for testing
    Fontcustom::Watcher.new opts
  end

  context "#watch" do
    it "should call generators on init" do
      Fontcustom::Generator::Font.should_receive(:start).once
      Fontcustom::Generator::Template.should_receive(:start).once
      w = watcher(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "output"
      )
      # silence output
      capture(:stdout) do
        w.watch
        w.stop
      end
    end

    it "should not call generators on init if options[:skip_first] is passed" do
      Fontcustom::Generator::Font.should_not_receive(:start)
      Fontcustom::Generator::Template.should_not_receive(:start)
      w = watcher(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "output",
        :skip_first => true
      )
      capture(:stdout) do
        w.watch
        w.stop
      end
    end

    it "should call generators when vectors change" do
      Fontcustom::Generator::Font.should_receive(:start).once
      Fontcustom::Generator::Template.should_receive(:start).once
      w = watcher(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "output",
        :skip_first => true
      )
      capture(:stdout) do
        begin
          w.watch
          FileUtils.cp fixture("shared/vectors/C.svg"), fixture("shared/vectors/test.svg")
          sleep 1
        ensure
          w.stop
          new = fixture("shared/vectors/test.svg")
          FileUtils.rm(new) if File.exists?(new)
        end
      end
    end

    it "should call generators when watched templates change" do
      Fontcustom::Generator::Font.should_receive(:start).once
      Fontcustom::Generator::Template.should_receive(:start).once
      w = watcher(
        :project_root => fixture,
        :input => {:vectors => "shared/vectors", :templates => "shared/templates"},
        :templates => %w|css preview custom.css|,
        :output => "output",
        :skip_first => true
      )
      capture(:stdout) do
        begin
          template = fixture "shared/templates/custom.css"
          content = File.read template
          new = content + "\n.bar { color: red; }"

          w.watch
          File.open(template, "w") { |file| file.write(new) }
          sleep 1
        ensure
          w.stop
          File.open(template, "w") { |file| file.write(content) }
        end
      end

    end

    it "should do nothing when non-vectors change" do
      Fontcustom::Generator::Font.should_not_receive(:start)
      Fontcustom::Generator::Template.should_not_receive(:start)
      w = watcher(
        :project_root => fixture,
        :input => "shared/vectors",
        :output => "output",
        :skip_first => true
      )
      capture(:stdout) do
        begin
          w.watch
          FileUtils.touch fixture("shared/vectors/non-vector-file")
        ensure
          w.stop
          new = fixture("shared/vectors/non-vector-file")
          FileUtils.rm(new) if File.exists?(new)
        end
      end
    end
  end
end
