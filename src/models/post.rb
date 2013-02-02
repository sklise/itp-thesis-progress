class Post
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :published_at, DateTime

  property :slug, Slug
  property :title, String, length: 255
  property :content, Text
  property :active, Boolean, default: true
  property :draft, Boolean

  property :announcement, Boolean, default: false

  property :user_id, Integer, required: true
  property :category_id, Integer, required: false
  property :assignment_id, Integer, required: false

  belongs_to :category
  belongs_to :assignment
  belongs_to :user
  has n, :comments, :constraint => :destroy

  self.per_page = 10

  before :save do
    publish
    ensure_slug
  end

  #
  # CLASS METHODS
  #
  def self.announcements
    all(:announcement => true, :order => :published_at.desc)
  end

  def self.by_students
    all(:announcement => false, :order => :published_at.desc)
  end

  def self.drafts
    all(draft: true, active: true, order: :updated_at.desc)
  end

  def self.published
    all(draft: false, active: true, order: :published_at.desc)
  end

  #
  # INSTANCE METHODS
  #
  def delete
    self.update(active: false)
  end

  def ensure_slug
    if self.slug.nil? || self.slug == ""
      self.slug = ((self.title == "") ? "untitled" : self.title[0..15])
    end
  end

  def date
    self.draft ? self.updated_at : self.published_at
  end

  def publish
    if self.title.nil? || self.title == ""
      self.title = "Untitled"
    end

    if !self.draft && self.published_at.nil?
      self.published_at = DateTime.now
    end
  end

  def published
    if self.published_at
      published_at.strftime("%B %e, %Y")
    else
      false
    end
  end

  def url
    "/students/#{self.user.netid}/#{self.id}/#{self.slug}"
  end
end