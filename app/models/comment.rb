class Comment < ApplicationRecord
  paginates_per 10
  belongs_to :post
  belongs_to :user
  has_many :votes
  mount_uploader :image, ImageUploader

  def total_likes
    votes.where(value: 1).count
  end

  def total_dislikes
    votes.where(value:-1).count
  end
end


# def total_votes
#   votes.pluck(:value).sum
# end
