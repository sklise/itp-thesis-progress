# Public: This app is used to receive image uploads from a post or announcemnt
# form and saves them to Amazon S3
class AttachmentsApp < Sinatra::Base
  before do
    env['warden'].authenticate!
  end

  post '/' do
    content_type :json

    image = {
      uid: params[:attachment][:uid],
      title: params[:attachment][:name],
      img_path: params[:attachment][:uid] + "/" + params[:attachment][:name],
      img_host: "http://itp-thesis.s3.amazonaws.com/",
      file: params[:attachment][:file][:tempfile]
    }

    AWS::S3::Base.establish_connection!(:access_key_id => ENV['S3_ACCESS_KEY'], :secret_access_key => ENV['S3_SECRET_KEY'])
    AWS::S3::S3Object.store(image[:img_path], open(image[:file]), "itp-thesis", access: :public_read)

    url = image[:img_host]+image[:img_path]

    {img_url: url}.to_json
  end

  post '/resources' do
    require_admin
    content_type :json

    image = {
      title: params[:attachment][:name],
      img_path: "resources/" + params[:attachment][:name],
      img_host: "http://itp-thesis.s3.amazonaws.com/",
      file: params[:attachment][:file][:tempfile]
    }

    AWS::S3::Base.establish_connection!(:access_key_id => ENV['S3_ACCESS_KEY'], :secret_access_key => ENV['S3_SECRET_KEY'])
    AWS::S3::S3Object.store(image[:img_path], open(image[:file]), "itp-thesis", access: :public_read)

    url = image[:img_host]+image[:img_path]

    {img_url: url}.to_json
  end
end