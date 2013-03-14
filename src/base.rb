module Sinatra
  class Base
    set :logging, true
    set :cache, Dalli::Client.new
    set :enable_cache, true

    if ENV['RACK_ENV'] == 'production'
      set :raise_errors, Proc.new { false }
      set :show_exceptions, false

      error do
        StatHat::API.ez_post_value("ERROR : #{request.fullpath}", ENV['STATHAT_EMAIL'], 1)

        email_body = ""

        if @current_user
          email_body += "CURRENT_USER: #{@current_user}\n\n"
        end

        email_body += env['sinatra.error'].backtrace.join("\n")
        send_email("ERROR: #{request.fullpath}", email_body)

        erb :'../../views/error'
      end
    end

    get '/test' do
      "#{File.dirname(__FILE__)} #{__FILE__}"
    end

    not_found do
      StatHat::API.ez_post_value("ERROR : NOT FOUND", ENV['STATHAT_EMAIL'], 1)
      flash.error = "Could not find #{request.fullpath}"
      redirect "/"
    end

  end
end