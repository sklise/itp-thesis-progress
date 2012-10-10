require 'bundler'
Bundler.require

# $LOAD_PATH.unshift(::File.expand_path('app', ::File.dirname(__FILE__)))

Dir["./app/*.rb"].each {|file| require file }

run Rack::URLMap.new(
  "/" => ThesisApp.new,
  "/progress" => ProgressApp.new
)