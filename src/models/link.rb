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