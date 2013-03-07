module Sinatra
  class Base
    include Rack::Utils

    helpers do

      def send_email(email_subject, email_body)
        Pony.mail({
          to: 'sk3453@nyu.edu',
          from: ENV['GMAIL_ADDRESS'],
          via: :smtp,
          via_options: {
            address:                'smtp.gmail.com',
            port:                   587,
            enable_starttls_auto:   true,
            user_name:              ENV['GMAIL_ADDRESS'],
            password:               ENV['GMAIL_PASSWORD'],
            authentication:         :plain,
            domain:                 'itp.nyu.edu'
          },
          subject: email_subject,
          body: email_body
        })
      end

      def error_logging(request, current_user)
        StatHat::API.ez_post_value("ERROR", ENV['STATHAT_EMAIL'], 1)

        email_body = "#{request.request_method} : #{request.fullpath}\n\n\n"

        if current_user
          email_body += "CURRENT_USER: #{current_user}\n\n"
        end

        email_body += env['sinatra.error'].inspect + "\n\n"

        email_body += env['sinatra.error'].backtrace.join("\n")
        send_email("ERROR: #{request.fullpath}", email_body)

        erb :'../../views/error'
      end

      alias_method :h, :escape_html

      #########################################################################
      #
      # AUTHENTICATION CHECKS
      #
      #########################################################################

      def require_advisor
        unless env['warden'].user.advisor?
          flash.error = "You are not authorized to access that page."
          redirect '/'
        end
      end

      # Require either advisor or resident, a non-student that is directly
      # involved in the class.
      def require_admin
        unless env['warden'].user.advisor? || env['warden'].user.resident?
          flash.error = "You are not authorized to access that page."
          redirect '/'
        end
      end

      # Advisor, Faculty or Resident
      def require_non_student
        unless env['warden'].user.non_student?
          flash.error = "You are not authorized to access that page."
          redirect '/'
        end
      end

      def check_user(netid)
        unless env['warden'].user.netid == netid
          flash.error = "That page belongs to #{netid}"
          redirect request.referrer
        end
      end

      #########################################################################
      #
      # VIEW HELPERS
      #
      #########################################################################

      # Public: Basic date formatting for the entire site.
      def longdate(d)
        d.strftime("%b %d")
      end

      def shortdate(d)
        d.strftime("%m/%d")
      end

      def list(collection, options)
        return options[:default] if collection.length == 0

        set = []
        collection.each do |c|
          set.push "<a href='#{c.url}'>#{c[options[:attribute]]}</a>"
        end

        set.join(", ")
      end

      def mdown(content)
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
        :autolink => true, :space_after_headers => true)
        marked = markdown.render(content || "")
        Nokogiri::HTML(marked).css('body').inner_html
      end

      def excerpt(content)
        words = content.split(/ /)

        words[29] += " <em>...</em>" if words.length > 30

        Nokogiri::HTML(mdown(words[0..29].join(" "))).css('body').inner_html
      end
    end
  end
end