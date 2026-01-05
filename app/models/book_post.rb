class BookPost < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 100 }
  validates :author, presence: true, length: { maximum: 50 }
  validates :body, presence: true, length: { maximum: 1000 }

  def liked_by?(user)
    return false unless user
    likes.exists?(user_id: user.id)
  end
end
