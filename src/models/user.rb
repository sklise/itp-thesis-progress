class User
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :netid, String
  property :first_name, String
  property :last_name, String
  property :password, String
  property :year, Integer
  property :role, String, default: "student"

  # Scopes
  def self.advisors
    all role: "advisor"
  end

  def self.students(year=nil)
    if year.nil?
      all(role: "student")
    else
      all(role: "student", year: year)
    end
  end

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

  # Return whether or not user is an advisor.
  def advisor?
    role == "advisor"
  end

  # Return User's posts that are assignments
  def completed_assignments
    if self.posts.length == 0
      []
    else
      assignment_posts = self.posts.all(:assignment_id.not => nil)

      assignment_ids = []

      assignment_posts.each do |post|
        assignment_ids << post.assignment_id
      end

      assignment_ids
    end
  end

  #
  def open_assignments
    if advisor?
      return []
    end

    assignments = []

    sections.each do |section|
      section.assignments.each do |assignment|
        assignments << assignment if !completed_assignments.include? assignment.id
      end
    end

    assignments
  end

  def self.has_application(yes_or_no=nil)
    if yes_or_no.nil? || yes_or_no
      self.all(:application.not => nil)
    else
      self.all(:application => nil)
    end
  end

  def to_s
    "#{first_name} #{last_name}"
  end

  has 1, :thesis
  has 1, :application
  has n, :posts
  has n, :announcements
  has n, :sections, through: Resource
end