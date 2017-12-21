class CommentsApi < ApplicationApi
  model Comment

  default_scope :all

  scope :scope1, &:all
  scope :scope2, &:all

  attribute(:id2) { |x| x.id * 2 }
end
