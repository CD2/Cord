module Cord
  class ApiBaseController < ::ApplicationController
    include Helpers

    def respond
      data = {}
      Array.wrap(params[:_json]).each do |body|
        body = body.permit!.to_hash.with_indifferent_access
        api = load_api(body[:api])
        data[api] = body
      end
      render json: prepare_json(data)
    end

    def prepare_json data
      # dumb version for now

      data.map do |api, body|
        blob = { table: api.resource_name }
        if body[:ids]
          blob[:ids] = body[:ids].map { |x| api.render_ids x }
        end
        if body[:records]
          blob[:records] = body[:records].map { |x| api.render_records x[:ids], x[:attributes] }
        end
        blob
      end
    end

    def perform_actions *args

    end

    def load_ids api, *args

    end

    def load_records api, ids = [], attributes = []

      # for each attribute, try to find a macro, else try to find an attribute, else error
    end
  end
end


# actions first to ensure data changes are reflected in response
# then ids, saving the results for use later as variables
# then records:
#  - examine attributes for precedence, eg. ArticlesApi has 'comments' as a requested attribute,
#    try to order than before CommentsApi
#  - finalize order to honour as many precedence constraints
#  - substitute in variables from ids calls
#  - render every api response, each of which having the option of extending the render queue
#  - if there are any remaining queue items (not in our planned order), repeat all record steps
