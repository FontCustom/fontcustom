# Contributor Guidelines

Thanks for helping make Font Custom better. This project was born out of an overheard conversation between two devs in a NYC coffee shop — it's come a long ways thanks to the support of folks like you.

## Conventions

We try to follow the [Github ruby styleguide](https://github.com/styleguide/ruby) as much as possible. 

If you catch a typo or a particularly unsightly piece of code — please _do_ let us know. No such thing as too small of an improvement.

## Process

* Visit [issues](https://github.com/FontCustom/fontcustom/issues) for ideas.
* Fork the repo.
* Create a topic branch. `git checkout -b my_sweet_feature`
* Add your tests. Run tests with `rake`.
* Develop your feature.
* Once all tests are passing, submit a pull request!

## On a Mac

Developing Fontcustom on a Mac could involve the following steps.

```sh
# Install Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

# Or update Homebrew
brew doctor
brew update

# Install Ruby
brew install rbenv ruby-build
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
rbenv install 2.0.0-p247
rbenv rehash

# Switch to using the new Ruby (global) or
#   or
# Switch to using the new Ruby for the current folder
#   or
# Switch to using the new Roby for the current shell
rbenv global 2.0.0-p247
#rbenv local 2.0.0-p247
#rbenv shell 2.0.0-p247


#
# Alt 1. Bundler
#

# Install Bundler
gem install bundler
rbenv rehash

# Setup Bundler
mkdir ~/.bundle
touch ~/.bundle/config
echo 'BUNDLE_PATH: vendor/bundle' >> ~/.bundle/config

# Bundle install Fontcustom
bundle install

# Build example fonts
cd example/testicon
bundle exec fontcustom compile .
cd example/testicon-custom
bundle exec fontcustom compile .


#
# Alt 2. Build & install gem
#

gem build fontcustom.gemspec
gem install fontcustom-XXX.gem

# Build example fonts
cd example/testicon
fontcustom compile .
cd example/testicon-custom
fontcuston compile .


#
# Test
#

# Test all
rake

# Install Rspec for testing
# http://rspec.info
gem install rspec

# Run specific test
rspec spec/fontcustom/generator/font_spec.rb

# Pull latest changes from FontCustom/fontcustom.git
git remote add fontcustom git@github.com:FontCustom/fontcustom.git
git pull fontcustom master
```

Read more:
* http://createdbypete.com/articles/ruby-on-rails-development-with-mac-os-x-mountain-lion/
* http://guides.rubygems.org/make-your-own-gem/

