class NotesApi < ApplicationApi
  model Comment

  default_scope do |driver|
    current_user ? driver.where(id: current_user.comments) : driver.none
  end
end

class ArticlesApi < ApplicationApi
  default_scope &:published

  attribute :image, default: true

  associations :videos, :images, :author
  # == Generates ==>
    # via driver reflection
    has_many :videos
    has_many :images
    belongs_to :author
  # <===============

  has_many :comments, api: NotesApi
  # == Generates ==>
    attribute :comment_ids do |record|
      record.comments.ids
    end

    attribute :comment_count do |record|
      has?(:comment_ids) ? get(:comment_ids).size : record.comments.count
    end

    macro :comments, uses: NotesApi do |options|
      result = render_attribute(:comment_ids)
      load_records(NotesApi, result, options)
    end
  # <===============

  attribute :first_comment_id do |record|
    get(:comment_ids).first
  end
end
