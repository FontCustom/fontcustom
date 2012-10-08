class Fontcustom::Base
  def self.compile(dir)
    check_dependencies
    path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    %x| fontforge -script #{path}/fontcustom/scripts/generate.py #{dir} |
  end

  def self.check_dependencies
    if `which python`.empty? || `which fontforge`.empty?
      abort "Whoops. It doesn't look like FontForge is installed on your system. Please run `brew install fontforge` and try me again!"
    end
  end
end
