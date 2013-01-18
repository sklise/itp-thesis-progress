require 'json'

class CommentsApp < Sinatra::Base
  before do
    env['warden'].authenticate!
  end

  post '/new' do
    content_type :json

    @comment = Comment.new({
      content: params[:content],
      user_id: params[:userId],
      post_id: params[:postId]
    })

    if @comment.save
      {success: 'comment created', comment: {
        username: @comment.user.to_s,
        date: @comment.created_at.strftime("%m/%d"),
        content: mdown(@comment.content)
      }}.to_json
    else
      {error: 'could not create comment', comment: @comment}.to_json
    end
  end

  post '/delete' do
    content_type :json

    @comment = Comment.get(params[:id])
    if @comment.destroy
      {success: 'comment deleted', id: params[:id]}
    else
      {error: 'Could not delete comment', id: params[:id]}
    end
  end
end