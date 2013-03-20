require 'spec_helper'

describe Fontcustom::Util do
  context '#root' do
    it 'should return #{gem_root}/lib/fontcustom/' do
      version = File.join(Fontcustom::Util.root, 'version.rb')
      File.exists?(version).should be_true
    end
  end

  context '#verify_*' do
    it 'should check if fontforge is installed'

    it 'should check that input dir exists'

    it 'should check that input dir contains vectors' 
  end
end
