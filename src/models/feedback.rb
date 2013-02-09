class Feedback
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :active, Boolean, default: true

  property :is_private, Boolean, default: true
  property :content, Text, default: ""
  property :thumbs_up, Boolean, default: true

  belongs_to :reviewer, 'User', key: true
  belongs_to :reviewee, 'User', key: true
end