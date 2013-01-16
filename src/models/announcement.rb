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
  property :issue, Integer, writer: :private
  property :year, Integer, default: DateTime.now.year, writer: :private
  property :everyone, Boolean, default: false

  property :user_id, Integer, required: true

  belongs_to :user
  has n, :sections, through: Resource

  self.per_page = 15

  attr_accessor :section_ids

  before :save, :publish
  before :save, :add_sections

  def self.last_announcement
    self.max(:issue)
  end

  def add_sections
    if self.section_ids.nil?
      self.everyone = true
    else
      self.everyone = false
    end

    if self.section_ids
      self.section_ids.each do |section_id|
        self.sections.push Section.first(id: section_id)
      end
    end
  end

  def publish
    if !draft && published_at.nil?
      self.published_at = DateTime.now
      self.issue = (Announcement.max(:issue) || 0) + 1
    end
    true
  end
end