class Assignment
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  property :title, String
  property :brief, Text
  property :year, Integer, default: DateTime.now.year, writer: :private

  property :everyone, Boolean, default: false
  property :user_id, Integer

  has n, :posts
  has n, :sections, through: Resource
  belongs_to :user

  before :save, :add_sections

  attr_accessor :section_ids

  def url
    "/assignments/#{self.year}/#{self.id}"
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

end