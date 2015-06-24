require 'spec_helper'

describe Fontcustom::Base do
  before(:each) { allow(Fontcustom::Manifest).to receive(:write_file) }

  context '#compile' do
    context 'when [:checksum][:current] equals [:checksum][:previous]' do
      it "should show 'no change' message" do
        allow(Fontcustom::Base).to receive(:check_fontforge)
        options = double('options')
        allow(options).to receive(:options).and_return({})
        allow(Fontcustom::Options).to receive(:new).and_return options

        output = capture(:stdout) do
          base = Fontcustom::Base.new({})
          manifest = base.instance_variable_get :@manifest
          expect(manifest).to receive(:get).and_return previous: 'abc'
          expect(base).to receive(:checksum).and_return 'abc'
          base.compile
        end
        expect(output).to match(/No changes/)
      end
    end
  end

  context '.check_fontforge' do
    it "should raise error if fontforge isn't installed" do
      allow_any_instance_of(Fontcustom::Base).to receive(:"`").and_return('')
      expect { Fontcustom::Base.new(option: 'foo') }.to raise_error Fontcustom::Error, /fontforge/
    end
  end

  context '.checksum' do
    it 'should return hash of all vectors and templates' do
      pending 'SHA2 is different on CI servers. Why?'
      allow(Fontcustom::Base).to receive(:check_fontforge)
      base = Fontcustom::Base.new(input: { vectors: fixture('shared/vectors') })
      base.instance_variable_set :@options,         templates: Dir.glob(File.join(fixture('shared/templates'), '*'))
      hash = base.send :checksum
      hash.should == '81ffd2f72877be02aad673fdf59c6f9dbfee4cc37ad0b121b9486bc2923b4b36'
    end
  end
end
