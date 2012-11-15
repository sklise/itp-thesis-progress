require 'data_mapper'
require 'dm-postgres-adapter'
require 'will_paginate'
require 'will_paginate/data_mapper'

DataMapper.setup(:default,
  ENV['DATABASE_URL'] || "postgres://localhost/thesisprog")

class Post
  include DataMapper::Resource

  property :id, Serial, key: true
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
  property :name, String
  property :year, Integer

  has n, :posts

  def to_s
    name
  end
end

class Link
  include DataMapper::Resource

  property :id, Serial
  property :type, String
  property :url, String
  property :name, String

  property :thesis_id, Integer

  belongs_to :thesis

  def anchor_tag
    "<a href='#{url}' target='_blank'>#{name}</a>"
  end
end

class Section
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  def students
    users.all(:role => "student")
  end

  def advisor
    users.first(:role => "advisor")
  end

  has n, :assignments, through: Resource
  has n, :users, through: Resource
end

class Assignment
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :brief, Text

  property :due_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :posts
  has n, :sections, through: Resource
end

class Thesis
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :elevator_pitch, Text
  property :description, Text
  property :image, String

  property :user_id, Integer

  belongs_to :user
  has n, :links
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :netid, String
  property :password, String
  property :year, Integer
  property :role, String

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

  def completed_assignments
    post.all(:assignment_id.not => nil)
  end

  has 1, :thesis
  has n, :posts
  has n, :sections, through: Resource
end

DataMapper.finalize
DataMapper.auto_upgrade!