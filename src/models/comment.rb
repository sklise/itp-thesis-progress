# Public: Comments are for feedback to student posts.
class Comment
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime

  property :read, Boolean, default: false # Make "read" a comment w content=''

  property :content, Text
  property :post_id, Integer
  property :user_id, Integer

  belongs_to :post
  belongs_to :user

  self.per_page = 50

  def self.read
    all(read: true)
  end

  def self.read_by
    ids = []

    read.all(fields: [:user_id]).each do |c|
      ids << c.user_id
    end

    ids
  end

  def self.text
    all(read: false)
  end
end