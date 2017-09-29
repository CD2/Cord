require_relative 'dsl'
module Cord
  class BaseApi
    include DSL
    include ActiveSupport::Callbacks

    define_callbacks :before_action

    def self.before_action &block
      set_callback :before_action, :before, &block
    end

    def run_before_callbacks
      run_callbacks :before_action
    end


    # class Record
    #
    #   def save
    #     run_callbacks :save do
    #       puts "- save"
    #     end
    #   end
    # end
    #
    # class PersonRecord < Record
    #   set_callback :save, :before, :saving_message
    #   def saving_message
    #     puts "saving..."
    #   end
    #
    #   set_callback :save, :after do |object|
    #     puts "saved"
    #   end
    # end



    def initialize controller, params
      @controller = controller
      @params = params
    end

    def controller
      @controller
    end

    def ids
      dri = params[:sort].present? ? sorted_driver : driver
      ids = {all: dri.all.map(&:id)}
      scopes.each do |name, block|
        ids[name] = instance_exec(dri, &block).all.map(&:id)
      end
      render model.table_name => {ids: ids}
      @response
    end

    def get(options={})
      records, aliases = filter_records(driver.all, options[:ids] || [])

      allowed_attributes = if (options[:attributes].present?)
        white_list_attributes(options[:attributes])
      else
        []
      end

      joins = join_dependencies.values_at(*allowed_attributes)
      records = perform_joins(records, joins)

      records_json = []
      records.each do |record|
        if columns.any?
          record_json = record.as_json(
            only: columns, except: ignore_columns
          )
        else
          record_json = record.as_json(
            except: ignore_columns
          )
        end
        allowed_attributes.each do |attr_name|
          record_json[attr_name] = instance_exec(record, &attributes[attr_name])
        end
        records_json.append(record_json)
      end

      response_data = {}
      response_data[:records] = records_json
      response_data[:aliases] = aliases if aliases.any?
      render model.table_name => response_data

      @response
    end

    def sorted_driver
      col, dir = params[:sort].split(' ')
      unless dir.in?(%w[ASC DESC])
        error "sort direction must be either DESC or ASC, instead got #{dir}"
        return driver
      end
      if sort_block = self.sorts[col]
        instance_exec(driver, dir, &sort_block)
      else
        error "unknown sort #{col}"
        driver
      end
    end

    def perform action_name
      if ids = params[:ids]
        action = member_actions[action_name]
        if (action)
          driver.where(id: ids).find_each do |record|
            instance_exec(record, &action)
          end
        else
          error('no action found')
        end
      else
        action = collection_actions[action_name]
        if (action)
          instance_exec &action
        else
          error('no action found')
        end
      end
      @response
    end

    def method_missing *args, &block
      controller.send(*args, &block)
    end

    protected

    def params
      @params
    end

    def render data
      @response ||= {}
      @response.merge! data
    end

    def redirect path
      render status: :redirect, url: path
    end

    def error message
      render error: message
    end

    def error_for record, message
      render error_for: { record: record, message: message}
    end

    private

    def white_list_attributes(attrs)
      blacklist = attrs - attribute_names - model.column_names
      error("Unknown attributes: #{blacklist.join(', ')}") if blacklist.any?
      attrs & attribute_names
    end

    def filter_records records, ids
      return [records.none, {}] unless ids.any?
      filter_ids = Set.new
      aliases = {}
      ([:id] + secondary_keys).each do |key|
        records.klass.where(key => ids).pluck(:id, key).each do |id, value|
          aliases[value] = id if value
          filter_ids << id
        end
      end
      [records.where(id: filter_ids.to_a), aliases]
    end

    def perform_joins records, joins
      return records unless joins.any?
      records.includes(*joins).references(*joins)
    end
  end
end
