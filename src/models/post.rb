class Post
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :published_at, DateTime
  property :active, Boolean, default: true

  property :title, String, length: 255, default: "Untitled"
  property :slug, Slug
  property :content, Text
  property :draft, Boolean, default: true

  property :user_id, Integer, required: true
  property :category_id, Integer, required: false
  property :assignment_id, Integer, required: false
  belongs_to :category
  belongs_to :assignment
  belongs_to :user

  has n, :comments, constraint: :destroy

  self.per_page = 10

  before :save do
    publish
    ensure_slug
  end

  #############################################################################
  #
  # CLASS METHODS
  #
  #############################################################################

  # Public: Return all active resources marked as drafts, sorted in reverse
  # chronological order by updated_at.
  #
  # Returns a DataMapper Collection.
  def self.drafts
    all(draft: true, active: true, order: :updated_at.desc)
  end

  # Public: Return all active resources marked as published, sorted in reverse
  # chronological order by published time.
  #
  # Returns a DataMapper Collection.
  def self.published
    all(draft: false, active: true, order: :published_at.desc)
  end

  #############################################################################
  #
  # INSTANCE METHODS
  #
  #############################################################################

  # Public: Instead of removing a model from the DB, mark it as inactive. This
  # is to make deletions recoverable and make it unnecessary to detach all
  # associations before deletion.
  #
  # Returns the result of the update call.
  def delete
    self.update(active: false)
  end

  # Public: Returns a string representing the path to this resource.
  #
  # Returns a string.
  def url
    "/students/#{self.user.netid}/#{self.id}/#{self.slug}"
  end

  private

  # Private: Ensure that self.slug is not an empty string or undefined. Set the
  # slug as a substring of the title.
  def ensure_slug
    if self.slug.nil? || self.slug == ""
      self.slug = self.title[0..15]
    end
  end

  # Private: Sets published date if resource is saved with draft==false. Will
  # only set the publish date on the first save unless resource is unpublished.
  # If a resource is a draft, unset published_at.
  def publish
    if self.draft
      self.published_at = nil
    else
      self.published_at ||= DateTime.now
    end
  end
end