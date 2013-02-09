class SiteConfig
  include DataMapper::Resource

  property :id, Serial
  property :updated_at, DateTime
  property :current_year, Integer
  property :thesis_lock, Boolean, default: false
end