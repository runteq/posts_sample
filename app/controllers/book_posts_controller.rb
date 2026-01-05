class BookPostsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_book_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  def index
    @book_posts = BookPost.includes(:user).order(created_at: :desc)
  end

  def show
    @comment = Comment.new
  end

  def new
    @book_post = current_user.book_posts.build
  end

  def create
    @book_post = current_user.book_posts.build(book_post_params)
    if @book_post.save
      redirect_to @book_post, notice: "投稿しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book_post.update(book_post_params)
      redirect_to @book_post, notice: "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book_post.destroy
    redirect_to root_path, notice: "削除しました"
  end

  private

  def set_book_post
    @book_post = BookPost.find(params[:id])
  end

  def authorize_user
    unless @book_post.user == current_user
      redirect_to root_path, alert: "権限がありません"
    end
  end

  def book_post_params
    params.require(:book_post).permit(:title, :author, :body, :image)
  end
end
