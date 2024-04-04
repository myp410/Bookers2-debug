class Book < ApplicationRecord
  include Notifiable
  
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { maximum: 200 }

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  def self.looks(search, word)
    @book = if search == 'perfect_match'
              Book.where('title LIKE?', "#{word}")
            elsif search == 'forward_match'
              Book.where('title LIKE?', "#{word}%")
            elsif search == 'backward_match'
              Book.where('title LIKE?', "%#{word}")
            elsif search == 'partial_match'
              Book.where('title LIKE?', "%#{word}%")
            else
              Book.all
            end
  end
  
  after_create do
    records = user.followers.map do |follower|
      notifications.new(user_id: follower.id)
    end
    Notification.import records
  end
  
  def notification_message
    "フォローしている#{user.name}さんが#{title}を投稿しました"
  end
  
  def notification_path
    book_path(self)
  end  
  
end
