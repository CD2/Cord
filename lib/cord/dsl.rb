module Cord
  module DSL
    extend ActiveSupport::Concern

    included do

      undelegated_methods = methods

      class << self
        def default_scopes
          @default_scopes ||= {}
        end

        def scopes
          @scopes ||= {}
        end

        def attributes
          @attributes ||= {}
        end

        def driver
          default_scopes.inject(model.all) do |driver, scope|
            apply_scope(driver, *scope)
          end
        end
      end

      delegate *(methods - undelegated_methods), to: :class

      class << self
        def model value = nil
          if value
            raise ArgumentError, 'expected an ActiveRecord model' unless is_model?(value)
            @model = value
            @model.column_names.each { |name| attribute name }
            default_attributes @model.column_names
          end
          @model
        end

        def default_attributes *values
          @default_attributes ||= []
          @default_attributes += values.flatten if values.any?
          @default_attributes
        end

        def resource_name value = nil
          if value
            @resource_name = value
          else
            @resource_name ||= model.table_name
          end
        end

        def default_scope name, &block
          name = normalize(name)
          default_scopes[name] = block || ->(x){ x.send(name) }
        end

        def scope name, &block
          name = normalize(name)
          scopes[name] = block || ->(x){ x.send(name) }
        end

        def attribute name, &block
          name = normalize(name)
          attributes[name] = block || ->(x){ x.send(name) }
        end

        def macro name, &block
          raise ArgumentError, 'macros require a block' unless block
          name = normalize(name)
          macros[name] = block
        end
      end

      def model
        self.class.model
      end

      def resource_name
        self.class.resource_name
      end

      def default_attributes
        self.class.default_attributes
      end
    end
  end
end
