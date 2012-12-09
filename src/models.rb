require 'data_mapper'
require 'dm-postgres-adapter'
require 'will_paginate'
require 'will_paginate/data_mapper'

# Require all files in ./src/models
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each {|file| puts file }

DataMapper.setup(:default,
  ENV['DATABASE_URL'] || "postgres://localhost/thesisprog")

# TAGS_________________________________________________________________________
class Tag
  include DataMapper::Resource

  property :id, Serial
  property :name, String
end

DataMapper.finalize
DataMapper.auto_upgrade!