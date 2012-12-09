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

  def save_from_form(form, user)
    self.description          = form[:description] || ""
    self.write_in             = form[:write_in_label] || ""
    self.strengths            = form[:strengths]|| ""
    self.help                 = form[:help]|| ""
    self.url                  = form[:url] || ""
    self.labels               = (form[:labels] || [""]).join(",")
    self.preferred_classmates = (form[:preferred_classmates] || [""]).join(",")
    self.user_id = user.id
  end

  def tags
    labels.split(",")
  end

  def requested
    preferred_classmates.split(",")
  end
end