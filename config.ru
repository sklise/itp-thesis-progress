require 'bundler'
Bundler.require

$LOAD_PATH.unshift(::File.expand_path('app', ::File.dirname(__FILE__)))

require 'app'
require 'models'
require 'helpers'

run Thesis