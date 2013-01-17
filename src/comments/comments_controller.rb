class CommentsApp < Sinatra::Base
  before do
    env['warden'].authenticate!
  end

  post '/new' do
    content_type :json
    @comment = Comment.new(
      content: params[:comment][:content],
      user_id: params[:comment][:user_id],
      post_id: params[:comment][:post_id])

    if @comment.save
      {success: 'comment created', comment: @comment}
    else
      {error: 'could not create comment', comment: @comment}
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