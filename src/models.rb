require 'data_mapper'
require 'dm-postgres-adapter'
require 'will_paginate'
require 'will_paginate/data_mapper'

DataMapper.setup(:default,
  ENV['DATABASE_URL'] || "postgres://localhost/thesisprog")

class Post
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :title, String
  property :content, Text
  property :private, Boolean

  property :created_at, DateTime
  property :updated_at, DateTime

  property :user_id, Integer, required: true
  property :category_id, Integer, required: false
  property :assignment_id, Integer, required: false

  belongs_to :category
  belongs_to :assignment
  belongs_to :user

  def published
    created_at.strftime("%B %e, %Y")
  end

  def url
    time = created_at.strftime("%Y/%m/%d")
    "/progress/#{time}/#{title}"
  end

  self.per_page = 10
end

class Category
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :name, String
  property :year, Integer

  has n, :posts

  def to_s
    name
  end
end

# LINK_________________________________________________________________________
class Link
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :type, String
  property :url, String
  property :name, String

  property :thesis_id, Integer

  belongs_to :thesis

  def anchor_tag
    "<a href='#{url}' target='_blank'>#{name}</a>"
  end
end

# SECTION______________________________________________________________________
class Section
  include DataMapper::Resource

  before :save, :ensure_slug

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :name, String
  property :year, Integer, default: Date.today.year
  property :slug, Slug

  def ensure_slug
    if self.slug.nil?
      self.slug = name.lowercase
    end
  end

  def path
    "/#{year}/#{slug}"
  end

  def students
    users.all(:role => "student")
  end

  def advisor
    users.first(:role => "advisor")
  end

  has n, :assignments, through: Resource
  has n, :users, through: Resource
end

# ASSIGNMENT___________________________________________________________________
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

# THESIS_______________________________________________________________________
class Thesis
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :title, String
  property :elevator_pitch, Text
  property :description, Text
  property :image, String

  property :user_id, Integer

  belongs_to :user
  has n, :links
end

# USER_________________________________________________________________________
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

  def self.students
    all role: "student"
  end

  def self.authenticate(netid, password)
    user = self.first(netid: netid)
    user if user && user.password == password
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

  has 1, :thesis
  has 1, :application
  has n, :posts
  has n, :sections, through: Resource
end

# APPLICATION__________________________________________________________________
class Application
  include DataMapper::Resource

  property :id, Serial
  property :description, Text
  property :write_in, Text
  property :strengths, Text
  property :help, Text
  property :url, Text

  property :labels, Text
  property :preferred_classmates, Text

  property :created_at, DateTime
  property :updated_at, DateTime

  property :user_id, Integer

  belongs_to :user

  attr_accessor :mutually_preferred, :preferred_by, :prefers
end

# TAGS_________________________________________________________________________
class Tag
  include DataMapper::Resource

  property :id, Serial
  property :name, String

end

DataMapper.finalize
DataMapper.auto_upgrade!