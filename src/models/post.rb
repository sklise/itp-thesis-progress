class Post
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :published_at, DateTime

  property :slug, Slug
  property :title, Text
  property :content, Text
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

  def ensure_slug
    if self.slug.nil? || self.slug == ""
      self.slug = ((self.title == "") ? "untitled" : self.title)
    end
  end

  def date
    self.draft ? self.updated_at : self.published_at
  end

  def publish
    if self.title.nil? || self.title = ""
      self.title = "Untitled"
    end

    if !self.draft && self.published_at.nil?
      self.published_at = DateTime.now
    end
  end

  def self.quick_new(params)
    content = params[:quickpost].split(/\r\n/)

    first_line = content.slice(0)

    title = first_line.split(" ").length < 10 ? content.slice!(0) : (content[0].split(" "))[0..9].join(" ") + "..."

    new(title: title, content: content.join("\r\n"), draft: params[:draft])
  end

  def self.announcements
    all(:announcement => true, :order => :published_at.desc)
  end

  def self.by_students
    all(:announcement => false, :order => :published_at.desc)
  end

  def self.drafts
    all(draft: true)
  end

  def published
    if self.published_at
      published_at.strftime("%B %e, %Y")
    else
      false
    end
  end

  def public_url
    "/students/#{self.user.netid}/#{self.id}/#{self.slug}"
  end

  def url
    public_url
  end
end