class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :book_post

  validates :body, presence: true, length: { maximum: 500 }
end
