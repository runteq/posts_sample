class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_book_post

  def create
    @comment = @book_post.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @book_post, notice: "コメントしました" }
      end
    else
      redirect_to @book_post, alert: "コメントできませんでした"
    end
  end

  def destroy
    @comment = @book_post.comments.find(params[:id])
    if @comment.user == current_user
      @comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @book_post, notice: "コメントを削除しました" }
      end
    else
      redirect_to @book_post, alert: "権限がありません"
    end
  end

  private

  def set_book_post
    @book_post = BookPost.find(params[:book_post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
