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

  property :personal_statement, Text
  property :design_process, Text
  property :production_process, Text
  property :user_testing, Text
  property :feedback, Text
  property :conclusions, Text
  property :next_steps, Text

  property :image, Text
  property :user_id, Integer

  belongs_to :user
  has n, :tags, through: Resource

  def permalink
    "http://thesis.itp.io/#{self.user.netid}/thesis"
  end
end