require 'spec_helper'

describe Fontcustom::Base do
  subject { Fontcustom::Base }

  it 'must fail if fontforge or python are missing' do
    skip 'TODO Is it sensible to test for testing of system dependencies? Moving on...'
    subject.check_dependancies.must_raise(Exception)
  end

  it 'must have a compile method' do
    subject.must_respond_to(:compile)
  end
end
