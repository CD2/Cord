require_relative 'crud'
require_relative 'dsl'
require_relative 'helpers'
require_relative 'json_string'

module Cord
  class BaseApi
    include CRUD
    include DSL
    include Helpers

    def initialize controller = nil
      @controller = controller
    end

    attr_reader :controller

    def render_ids hash
      result = {}
      (hash[:scopes] || []).each do |name|
        result[name] = apply_scope(driver, name, scopes[name]).ids
      end
      result
    end

    def render_records ids, attributes = []
      @records_json = []
      records = driver.where(id: ids)
      records.each do |record|
        @records_json << render_record(record, attributes)
      end
      @records_json
    end

    def render_record record, attributes = []
      @record = record
      @record_json = {}
      attributes = attributes.map { |x| normalize(x) } | default_attributes
      attributes.each do |attribute|
        @record_json[attribute] = render_attribute(attribute)
      end
      @record_json
    end

    def render_attribute attribute
      attribute = normalize(attribute)
      @record_json[attribute] = get(attribute)
    end

    def get attribute
      attribute = normalize(attribute)
      has?(attribute) ? @record_json[attribute] : calculate_attribute(attribute)
    end

    def has? attribute
      attribute = normalize(attribute)
      @record_json.has_key? attribute
    end

    def calculate_attribute(name)
      name = normalize(name)
      instance_exec(@record, &attributes[name])
    end

    def perform_macro(name)
      name = normalize(name)
      # sdfgpsidfj
    end

    private

    def method_missing *args, &block
      controller.send(*args, &block)
    end

    def respond_to_missing? method_name, *args, &block
      controller.respond_to?(method_name)
    end
  end
end
