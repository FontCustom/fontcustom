require 'spec_helper'

describe Fontcustom::Util do
  context '#root' do
    it 'should return #{gem_root}/lib/fontcustom/' do
      version = File.join(Fontcustom::Util.root, 'version.rb')
      File.exists?(version).should be_true
    end
  end

  context '#verify_*' do
    it "should raise error if fontforge isn't installed" do
      expect { Fontcustom::Util.verify_fontforge(`which fontforge-does-not-exist`) }.to raise_error(Thor::Error, /install fontforge/)
    end

    it "should raise error if input_dir doesn't exist" do
      expect { Fontcustom::Util.verify_input_dir(fixture('does-not-exist')) }.to raise_error(Thor::Error, /isn't a directory/)
    end

    it "should raise error if input_dir doesn't contain vectors" do
      expect { Fontcustom::Util.verify_input_dir(fixture('empty')) }.to raise_error(Thor::Error, /doesn't contain any vectors/)
    end
  end
end
