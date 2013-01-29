require 'bcrypt'

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :netid, String
  property :first_name, String
  property :last_name, String
  property :password_hash, BCryptHash
  property :year, Integer
  property :role, String, default: "student"

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def url
    "/students/#{self.netid}"
  end


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

  def student?
    role == "student"
  end

  def resident?
    role == "resident"
  end

  # Return a student's advisor. If the user is an advisor, return nil
  def students_advisor
    return nil if self.advisor?

    self.sections.first.advisor
  end

  # Return User's posts that are assignments
  def completed_assignments
    return [] if self.role != "student"

    if self.posts.length == 0
      []
    else
      assignment_posts = self.posts.all(:assignment_id.not => nil)
    end
  end

  # Just the ids of assignments completed by student
  def assignment_ids
    return [] if self.role != "student"

    assignment_posts = completed_assignments

    assignment_ids = []

    assignment_posts.each do |post|
      assignment_ids << post.assignment_id
    end

    assignment_ids
  end

  #
  def open_assignments
    return [] if self.role != "student"

    assignments = []

    sections.each do |section|
      section.assignments.each do |assignment|
        assignments << assignment if !assignment_ids.include? assignment.id
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
  has n, :assignments
  has n, :comments
  has n, :sections, through: Resource
end