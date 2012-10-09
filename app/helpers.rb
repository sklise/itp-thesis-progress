module Sinatra
  class Base
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end
  end
end