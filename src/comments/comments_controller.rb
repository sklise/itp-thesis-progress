require 'json'

class CommentsApp < Sinatra::Base
  before do
    env['warden'].authenticate!
  end

  post '/new' do
    content_type :json

    @comment = Comment.new({
      user_id: env['warden'].user.id, post_id: params[:postId]
    });

    if params[:read] == "true"
      @comment.read = true
    else
      @comment.content = params[:content]
    end

    if @comment.save
      {success: 'comment created', comment: {
        username: @comment.user.to_s,
        date: @comment.created_at.strftime("%m/%d"),
        read: @comment.read,
        content: mdown(@comment.content || "")
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