class Post
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :published_at, DateTime

  property :slug, Slug
  property :title, String
  property :content, Text
  property :draft, Boolean

  property :announcement, Boolean, default: false

  property :user_id, Integer, required: true
  property :category_id, Integer, required: false
  property :assignment_id, Integer, required: false

  belongs_to :category
  belongs_to :assignment
  belongs_to :user

  self.per_page = 10

  before :save do
    publish
    ensure_slug
  end

  def ensure_slug
    if self.slug.nil? || self.slug == ""
      self.slug = ((self.title == "") ? "untitled" : self.title)
    end
  end

  def date
    self.draft ? self.updated_at : self.published_at
  end

  def publish
    puts "yezzz"
    if !self.draft && self.published_at.nil?
      self.published_at = DateTime.now
    end
  end

  def self.quick_new(params)
    content = params[:quickpost].split(/\r\n/)
    title = content.slice!(0)

    new(title: title, content: content.join("\r\n"), draft: params[:draft])
  end

  def self.announcements
    all(:announcement => true, :order => :published_at.desc)
  end

  def self.by_students
    all(:announcement => false, :order => :published_at.desc)
  end

  def published
    if self.published_at
      published_at.strftime("%B %e, %Y")
    else
      false
    end
  end

  def url
    time = created_at.strftime("%Y/%m/%d")
    "/progress/#{time}/#{slug}"
  end
end