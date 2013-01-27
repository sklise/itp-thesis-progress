class Page
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime

  property :title, String
  property :slug, Slug, unique: true
  property :content, Text

  before :save, :ensure_slug

  def ensure_slug
    self.slug = self.title if (self.slug.nil? || self.slug == "")
  end

  def self.slugs
    all.map {|page| page.slug }
  end
end