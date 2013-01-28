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

  attr_accessor :section_ids

  before :save, :add_sections

  def url
    "/assignments/#{self.year}/#{self.id}"
  end

  # Look at sections_id attr_accessor and everyone, as well as sections to
  # either add or remove sections.
  def add_sections
    # If no section_ids were given and there are currently no associations.
    # Set `everyone` to true.
    if self.section_ids.nil? || self.sections.length == 0
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

end