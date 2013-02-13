require 'json'

class FeedbackApp < Sinatra::Base
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
      {success: 'feedback deleted', id: params[:id]}
    else
      {error: 'Could not delete feedback', id: params[:id]}
    end
  end
end