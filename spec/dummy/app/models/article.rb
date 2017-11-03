class Article < ApplicationRecord
  has_many :comments
  has_one :image

  enum article_type: %i[type_1 type_2 type_3]
end
