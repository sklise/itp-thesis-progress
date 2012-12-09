class Assignment
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  property :title, String
  property :brief, Text

  property :due_at, DateTime

  has n, :posts
  has n, :sections, through: Resource

  # Return list of assignments associated with the current user's sections.
  def self.own(user)
    assignments = all
    x = []
    assignments.each do |a|
      x << a.id if (a.sections & user.sections).length > 0
    end

    assignments.all(id: x, :order => :due_at.asc)
  end

  def year
    created_at.year
  end

end