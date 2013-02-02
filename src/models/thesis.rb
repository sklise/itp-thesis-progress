class Thesis
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  property :title, String, length: 255
  property :elevator_pitch, Text # Limit to 75 words
  property :description, Text # limit to 200 words
  property :reason, Text # limit to 150 words
  property :research_plan, Text # limit to 150 words
  property :link, String, length: 255

  property :image, Text

  property :user_id, Integer

  # 5 tags

  belongs_to :user
end