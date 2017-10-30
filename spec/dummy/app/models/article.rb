class Article < ApplicationRecord
  has_many :comments
  has_one :image
end
