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