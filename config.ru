require 'bundler'
Bundler.require
require 'bcrypt'


Dir["./src/*.rb"].each {|file| require file }
Dir["./src/*/*.rb"].each {|file| require file }

builder = Rack::Builder.new do
  use Rack::Session::Cookie, key: "ooooooohyeaaaaa"

  use OmniAuth::Builder do
    provider :saml,
      :assertion_consumer_service_url => "http://localhost:9393/auth/saml/callback",
      :issuer                         => "ITP Thesis Site Local",
      :idp_sso_target_url             => "http://itp.nyu.edu/simplesaml/saml2/idp/SSOService.php",
      :idp_cert                       => ENV['IDP_CERT']
  end

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
      raise params.inspect
      user = User.first(netid: params['user']['netid'])

      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

  use Rack::MethodOverride
  use Rack::Flash, accessorize: [:error, :success]

  # Hook up the apps

  map ('/')                     { run Main }

  map ('/admin')                { run AdminApp }
  map ('/announcements')        { run AnnouncementsApp }
  map ('/assignments')          { run AssignmentsApp }
  map ('/attachments')          { run AttachmentsApp }
  map ('/comments')             { run CommentsApp }
  map ('/feedback')             { run FeedbackApp }
  map ('/sections')             { run SectionsApp }
  map ('/session' )             { run AuthenticationManager }
  map ('/students')             { run StudentsApp }

  map ('/applications')         { run ApplicationApp }
  map ('/applications/submit')  { run ApplicationSubmit }

end

run builder