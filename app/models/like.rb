class Like < ApplicationRecord
  belongs_to :user
  belongs_to :book_post

  validates :user_id, uniqueness: { scope: :book_post_id }
end
