# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest' do
  # with Minitest::Spec
  #watch(%r|^spec/(.*)_spec\.rb|)
  #watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "spec/lib/#{m[1]}#{m[2]}_spec.rb" }
  #watch(%r|^spec/spec_helper\.rb|)    { "spec" }
  watch(%r|^lib/.+\.rb|)    { 'spec/lib/fontcustom_spec.rb' }
  watch(%r|^spec/.+\.rb|)    { 'spec/lib/fontcustom_spec.rb' }
end
