require 'json'

class FeedbackApp < Sinatra::Base

  if ENV['RACK_ENV'] == 'production'
    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    error do
      StatHat::API.ez_post_value("ERROR : #{request.fullpath}", ENV['STATHAT_EMAIL'], 1)

      email_body = ""

      if @current_user
        email_body += "CURRENT_USER: #{@current_user}\n\n"
      end

      email_body += env['sinatra.error'].backtrace.join("\n")
      send_email("ERROR: #{request.fullpath}", email_body)

      erb :'../../views/error'
    end
  end

  before do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    require_non_student
  end

  post '/new' do
    content_type :json

    @feedback = Feedback.new({
      reviewer_id: @current_user.id,
      reviewee_id: params[:feedback][:reviewee_id],
      content: params[:feedback][:content],
      thumbs_up: params[:feedback][:thumbs_up],
      thesis_id: params[:feedback][:thesis_id]
    });

    if @feedback.save
      {success: 'feedback created', feedback: @feedback.attributes}.to_json
      redirect request.referrer
    else
      {error: 'could not create feedback', feedback: @feedback.attributes}.to_json
    end
  end

  post '/delete' do
    content_type :json

    @feedback = Feedback.first(id: params[:id])

    @feedback.active = false


    if @feedback.save
      {success: 'feedback deleted', id: params[:id]}.to_json
      redirect request.referrer
    else
      {error: 'Could not delete feedback', id: params[:id]}
    end
  end
end