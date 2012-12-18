require 'bundler'
Bundler.require
require 'redcarpet'
require 'bcrypt'

Dir["./src/*.rb"].each {|file| require file }
Dir["./src/*/*.rb"].each {|file| require file }

builder = Rack::Builder.new do
  # Warden::Manager.serialize_into_session{|user| user.id }
  # Warden::Manager.serialize_from_session{|id| User[id] }

  # Warden::Manager.before_failure do |env,opts|
  #   env['REQUEST_METHOD'] = 'POST'
  # end

  # Warden::Strategies.add(:password) do
  #   def valid?
  #     params['user'] && params['user']['netid'] && params['user']['password']
  #   end

  #   def authenticate!
  #     user = User.authenticate(
  #       params['user']['netid'],
  #       params['user']['password']
  #     )
  #     user.nil? ? fail!('Could not log in') : success!(user, 'Successfully logged in')
  #   end
  # end

  use Rack::MethodOverride
  use Rack::Session::Cookie
  use Rack::Flash, accessorize: [:error, :success]
  # use Warden::Manager do |config|
  #   config.scope_defaults :default,
  #     strategies: [:password],
  #     action: 'session/unauthenticated'
  #   config.failure_app = self
  # end

  # Basic Authentication
  # use Rack::Auth::Basic, "Restricted Area" do |username, password|
  #   [username, password] == [ENV['USERNAME'], ENV['PASSWORD']]
  # end

  # Hook up the apps
  map ('/')               { run Main }
  # map ('/progress')       { run ProgressApp }
  # map ('/session' )       { run AuthenticationManager }
  # map ('/thesis' )        { run ThesisApp }
  # map ('/assignments')    { run AssignmentsApp }
  map ('/applications')   { run ApplicationApp }
  map ('/application/submit') { run ApplicationSubmit }
  # map ('/sections')       { run SectionsApp }
end

run builder