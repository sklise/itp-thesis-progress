require 'bundler'
Bundler.require
require 'redcarpet'
require 'bcrypt'

Dir["./src/*.rb"].each {|file| require file }
Dir["./src/*/*.rb"].each {|file| require file }

builder = Rack::Builder.new do
  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.get(id) }
    config.scope_defaults :default,
      strategies: [:password],
      action: 'session/unauthenticated'
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['netid'] && params['user']['password']
    end

    def authenticate!
      user = User.first(netid: params['user']['netid'])
      if user && user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

  use Rack::MethodOverride
  use Rack::Session::Cookie
  use Rack::Flash, accessorize: [:error, :success]

  # Hook up the apps

  map ('/')                     { run Main }
  map ('/progress')             { run ProgressApp }
  map ('/session' )             { run AuthenticationManager }
  map ('/thesis' )              { run ThesisApp }
  map ('/assignments')          { run AssignmentsApp }
  map ('/announcements')        { run AnnouncementsApp }
  map ('/applications')         { run ApplicationApp }
  map ('/applications/submit')  { run ApplicationSubmit }
  map ('/sections')             { run SectionsApp }
end

run builder