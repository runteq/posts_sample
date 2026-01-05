class LikesController < ApplicationController
  before_action :require_login
  before_action :set_book_post

  def create
    @like = current_user.likes.build(book_post: @book_post)
    @like.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @book_post }
    end
  end

  def destroy
    @like = current_user.likes.find_by(book_post: @book_post)
    @like&.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @book_post }
    end
  end

  private

  def set_book_post
    @book_post = BookPost.find(params[:book_post_id])
  end
end
