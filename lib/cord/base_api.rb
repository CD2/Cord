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
      records = driver.all
      if (options[:ids].present?)
        if secondary_keys.any?
          main_table = records.table_name
          query = ([:id] + secondary_keys).map do |key|
            subquery = records.model.where(key => options[:ids])
            unless subquery.select_values.any?
              subquery = subquery.select("\"#{main_table}\".*")
            end
            subquery = subquery.select(
              "CAST(\"#{main_table}\".\"#{key}\" AS TEXT) AS cord_key"
            )
            subquery.to_sql
          end
          query = query.join(' UNION ALL ')
          records = records.from("(#{query}) AS #{main_table}")
          if (records.references_values + records.eager_load_values).any?
            raise 'references() and eager_load() are unsupported when using multiple keys'
          end
          unless records.select_values.any?
            records = records.select("\"#{main_table}\".*")
          end
          records = records.select(:cord_key)
        else
          records = records.where(id: options[:ids])
        end
      end

      @aliases = {}
      allowed_attributes = if (options[:attributes].present?)
        white_list_attributes(options[:attributes])
      else
        []
      end
      records_json = []
      records.each do |record|
        if columns.any?
          record_json = record.as_json(
            only: columns, except: ignore_columns + [:cord_key]
          )
        else
          record_json = record.as_json(
            except: ignore_columns + [:cord_key]
          )
        end
        allowed_attributes.each do |attr_name|
          record_json[attr_name] = instance_exec(record, &attributes[attr_name])
        end
        if record.has_attribute?(:cord_key) && record.cord_key != record.id.to_s
          @aliases[record.cord_key] = record.id
        end
        records_json.append(record_json)
      end

      response_data = {}
      response_data[:records] = records_json.uniq { |x| x['id'] }
      response_data[:aliases] = @aliases if @aliases.any?
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

  end
end
