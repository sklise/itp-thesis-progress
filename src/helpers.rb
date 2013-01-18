module Sinatra
  class Base

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def require_admin
        unless env['warden'].user.advisor?
          flash.error = "You are not authorized to access that page."
          redirect '/'
        end
      end


      def list(collection, options)
        return options[:default] if collection.length == 0

        set = []
        collection.each do |c|
          set.push c[options[:attribute]]
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