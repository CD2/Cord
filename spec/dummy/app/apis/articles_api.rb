class ArticlesApi < ApplicationApi

  # # optional | autoloads all assocations and scopes (maybe methods?)
	# # api_for Article
  #
  driver {
    Article.includes(:comments)
  } # limit all results to a subset of the model

  scope :thing do |x|
    x.where(id: 1)
  end

  before_action(:a, only: :halting_action) { render a: 'ok!' }
  before_action(:b, only: :halting_action) { halt! }
  before_action(:c, only: :halting_action) { render c: 'ok!' }

  secondary_key :name

  action :halting_action do
    render status: 'complete!'
  end

  before_action :zzz, only: 6

  byebug

	# driver do
  #   if params[:tag]
  #     Article.published.where('body LIKE ?', "%#{params[:tag]}%")
  #   else
  #     Article.published
  #   end
	# end
  #
  # # columns :id, :name, :created_at #whitelist columns
  # ignore_columns :id, :name #blacklist columns
  #
	# scope :ordered   #Use a scope defined on the model
	# scope :published { where(published: false) } # custom scope which isnt on the model, required as cant chain scopes
  #
	has_many :comments
  has_many :comments1, joins: false
  has_many :comments2, joins: :sdfsdf

  attribute :joins_test, joins: :comments do |record|
    record.comments.count
  end

  ignore_columns :updated_at
	# belongs_to :author  # adds methods: author
	# # has_one :forum # adds methods: forum, forum_id
  #
	# attribute :view_count # adds attribute called view_count which calls same named model method
	attribute :score do |article| # attribute with block, block is passed the current record
		article.id * 10
	end

  #
  # ########## MUTATIONS
  #
  # permitted_params :name, :body, :created_at #blobvious
  # # before_create do |record| # callbacks
  # # after_create
  # # before_update
  # # after_update
  # # before_destroy
  # # after_destroy
  #
  # ########## ACTIONS
  #

  sort :name
  sort :updated_at


  action :vote_up do # collection method
    byebug
    driver.vote_up!
  end
  #
  action_for :update_x do |question| # member method (all members our found by id)
    byebug
    question.update(x: params[:x])
  end
  #
  # action :vote_down do
  #   error('cant vote down')    # returns error
  #   error_for(Question.first, 'cant vote down')    # returns error for a specific record
  # end

end
