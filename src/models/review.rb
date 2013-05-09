class Review
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime

  property :reviewer_id, Integer
  property :student_id, Integer
  property :student_name, String, length: 255
  property :thesis_title, String, length: 255

  property :proof_of_concept, Text
  property :strongest_part, Text
  property :project_life, Text
  property :presentation_quality, Text
end