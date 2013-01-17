# Public: Comments are for feedback to student posts.
class Comment
  include DataMapper::Resource

  property :id, Serial, key: true
  property :content, Text
  property :post_id, Integer
  property :user_id, Integer

  belongs_to :post
  belongs_to :user
end