module Sinatra
  class Base
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def list(collection, attribute)
        set = []
        collection.each do |c|
          set.push c[attribute]
        end

        set.join(", ")
      end

      def excerpt(content)
        words = content.split(" ")
        words[0..30].join(" ")
      end
    end
  end
end