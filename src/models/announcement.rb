# Announcement
# Public: Announcements are created by faculty to communicate with students.
# Announcements should be viewable to all students and should be easy to find.
class Announcement
  include DataMapper::Resource

  property :id, Serial, key: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :active, Boolean, default: true
  property :year, Integer, default: DateTime.now.year

  property :title, String, length: 255
  property :content, Text
  property :draft, Boolean, default: true
  property :published_at, DateTime
  property :everyone, Boolean, default: false

  property :user_id, Integer, required: true
  belongs_to :user

  has n, :sections, through: Resource

  self.per_page = 15

  before :save do
    publish
  end

  #############################################################################
  #
  # CLASS METHODS
  #
  #############################################################################

  # Public: Return all active resources marked as drafts, sorted in reverse
  # chronological order by updated_at.
  #
  # Returns a DataMapper Collection.
  def self.drafts
    all(draft: true, active: true, order: :updated_at.desc)
  end

  # Public: Return all active resources marked as published, sorted in reverse
  # chronological order by published time.
  #
  # Returns a DataMapper Collection.
  def self.published
    all(draft: false, active: true, order: :published_at.desc)
  end

  #############################################################################
  #
  # INSTANCE METHODS
  #
  #############################################################################

  def section_ids=(ids)
    self.sections = Section.all(:id => ids)
  end

  def section_ids
    self.sections.map {|section| section.id}
  end

  def send_email=(state)
    self.send_email
  end

  # Public: Instead of removing a model from the DB, mark it as inactive. This
  # is to make deletions recoverable and make it unnecessary to detach all
  # associations before deletion.
  #
  # Returns the result of the update call.
  def delete
    self.update(active: false)
  end

  # Public: Returns a string representing the path to this resource.
  #
  # Returns a string.
  def url
    "/announcements/#{self.year}/#{self.id}"
  end

  def send_email
    sender = "#{self.user.netid}@nyu.edu"

    emails = []

    self.sections.users.students.each do |student|
      if ENV['RACK_ENV'] == 'production'
        emails << "#{student.netid}@nyu.edu"
      else
        emails << "sk3453+#{student.netid}@nyu.edu"
      end
    end

    self.sections.users.residents.each do |resident|
      if ENV['RACK_ENV'] == 'production'
        emails << "#{resident.netid}@nyu.edu"
      else
        emails << "sk3453+#{resident.netid}@nyu.edu"
      end
    end

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
    :autolink => true, :space_after_headers => true)
    marked = markdown.render(self.content || "")

    Pony.mail({
      to: sender,
      bcc: emails.join(","),
      via: :smtp,
      via_options: {
        address:                'smtp.gmail.com',
        port:                   587,
        enable_starttls_auto:   true,
        user_name:              ENV['GMAIL_ADDRESS'],
        password:               ENV['GMAIL_PASSWORD'],
        authentication:         :plain,
        domain:                 'itp.nyu.edu'
      },
      from: sender,
      reply_to: sender,
      subject: "#{self.title}",
      html_body: marked.to_html,
      body: "#{self.content}"
    });
  end

  private

  # Private: Sets published date if resource is saved with draft==false. Will
  # only set the publish date on the first save unless resource is unpublished.
  # If a resource is a draft, unset published_at.
  def publish
    if self.draft
      self.published_at = nil
    else
      self.published_at ||= DateTime.now
    end
  end
end