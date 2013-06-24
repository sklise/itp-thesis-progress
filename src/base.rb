module Sinatra
  module ThesisApp
    def self.registered(app)
      app.configure do
        app.set :logging, true
        app.set :cache, Dalli::Client.new
        app.set :enable_cache, true

        app.set :static, true
        app.set :public_folder, Proc.new { File.join(File.dirname(__FILE__), "../../public") }

        app.set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }

        if app.production?
          app.set :raise_errors, false
          app.set :show_exceptions, false
        end
      end

      if app.production?
        app.error do
          email_body = ""

          if @current_user
            email_body += "CURRENT_USER: #{@current_user}\n\n"
          end

          email_body += env['sinatra.error'].backtrace.join("\n")
          send_email("ERROR: #{request.fullpath}", email_body)

          erb :error
        end

        app.not_found do
          flash.error = "Could not find #{request.fullpath}"
          redirect "/"
        end
      end

    end
  end
end