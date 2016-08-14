class Comment < ApplicationRecord
  paginates_per 10
  belongs_to :post
  belongs_to :user
  mount_uploader :image, ImageUploader



end
