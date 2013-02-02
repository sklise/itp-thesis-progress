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

  property :active, Boolean, default: true

  property :title, String, length: 255
  property :content, Text
  property :draft, Boolean, default: true
  property :published_at, DateTime
  property :year, Integer, default: DateTime.now.year, writer: :private
  property :everyone, Boolean, default: false

  property :user_id, Integer, required: true

  belongs_to :user
  has n, :sections, through: Resource

  self.per_page = 15

  attr_accessor :section_ids

  before :save, :publish
  before :save, :add_sections

  def self.drafts
    all(draft: true, active: true, order: :updated_at.desc)
  end

  def self.published
    all(draft: false, active: true, order: :published_at.desc)
  end

  def delete
    self.update(active: false)
  end

  # Look at sections_id attr_accessor and everyone, as well as sections to
  # either add or remove sections.
  def add_sections
    # If no section_ids were given a set `everyone` to true.
    if self.section_ids.nil?
      self.everyone = true
    else
      self.everyone = false

      self.section_ids.each do |section_id|
        next if !self.sections.get(section_id).nil?
        self.sections.push Section.first(id: section_id.to_i)
      end
    end

    # If `everyone` is true, add all of the sections that aren't already
    # associated.s
    if self.everyone == true
      all_sections = Section.all(year: Date.today.year)
      all_sections.each do |s|
        next if self.sections.include?(s)

        self.sections << s
      end
      return
    end
  end

  def publish
    if !draft && published_at.nil?
      self.published_at = DateTime.now
    end
    true
  end

  def url
    "/announcements/#{self.year}/#{self.id}"
  end
end