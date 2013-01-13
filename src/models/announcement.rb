# Announcement
# Public: Announcements are created by faculty to communicate with students.
# Announcements should be viewable to all students and should be easy to find.
#
# Announcements are either published or drafts and are sorted by published_at
# attribute.
class Announcement
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime

  property :title, String
  property :content, Text
  property :draft, Boolean, default: true
  property :published_at, DateTime
  property :issue, Integer
  property :year, Integer, default: DateTime.now.year, writer: :private

  property :user_id, Integer, required: true

  belongs_to :user
  has n, :sections, through: Resource

  self.per_page = 15

  before :save, :publish

  def self.last_announcement
    self.max(:issue)
  end

  def publish
    if !draft && published_at.nil?
      self.published_at = DateTime.now
      self.issue = (Announcement.max(:issue) || 0) + 1
    end
    true
  end
end