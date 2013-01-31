module Sinatra
  class Base

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def longdate(d)
        d.strftime("%b %d")
      end

      def require_admin
        unless env['warden'].user.advisor?
          flash.error = "You are not authorized to access that page."
          redirect '/'
        end
      end

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
        marked = markdown.render(content)
        marked.to_html
      end

      def excerpt(content)
        words = content.split(/ /)

        words[29] += " <em>...</em>" if words.length > 30

        mdown(words[0..29].join(" "))
      end
    end
  end
end