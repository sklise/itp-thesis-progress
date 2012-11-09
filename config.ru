require 'bundler'
Bundler.require
require 'rack/flash'
require 'redcarpet'

Dir["./src/*.rb"].each {|file| require file }
Dir["./src/*/*.rb"].each {|file| require file }

builder = Rack::Builder.new do
  Warden::Manager.serialize_into_session{|user| user.id }
  Warden::Manager.serialize_from_session{|id| User[id] }

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['netid'] && params['user']['password']
    end

    def authenticate!
      user = User.authenticate(
        params['user']['netid'],
        params['user']['password']
      )
      user.nil? ? fail!('Could not log in') : success!(user, 'Successfully logged in')
    end
  end

  use Rack::MethodOverride
  use Rack::Session::Cookie
  use Rack::Flash, accessorize: [:error, :success]
  use Warden::Manager do |config|
    config.scope_defaults :default,
      strategies: [:password],
      action: 'session/unauthenticated'
    config.failure_app = self
  end

  map '/' do
    run ThesisApp
  end

  map '/session' do
    run AuthenticationManager
  end

  map '/progress' do
    run ProgressApp
  end
end

run builder