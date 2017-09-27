module Cord
  module DSL

    def self.included(base)
      base.extend ClassMethods
    end

    def driver
      return @driver if @driver
      block = self.class.instance_variable_get(:@driver) || raise('No api driver set')
      @driver = instance_exec &block
    end

    def model
      return driver if driver <= ActiveRecord::Base
      driver.model
    end

    def sorts
      self.class.sorts
    end

    def before_actions
      self.class.before_actions
    end

    def around_actions
      self.class.around_actions
    end

    def after_actions
      self.class.after_actions
    end

    def columns
      self.class.columns
    end

    def ignore_columns
      self.class.ignore_columns
    end

    def scopes
      self.class.scopes
    end

    def attributes
      self.class.attributes
    end

    def member_actions
      self.class.member_actions
    end

    def collection_actions
      self.class.collection_actions
    end

    def attribute_names
      attributes.keys
    end

    module ClassMethods


      def abstract?
        @abstract || false
      end

      def abstract!
        @abstract = true
      end

      def driver driver=nil, &block
        block = -> { driver } unless block.present?
        @driver = block
      end

      def columns *cols
        @columns ||= []
        @columns += cols
      end

      def ignore_columns *cols
        @ignore_columns ||= []
        @ignore_columns += cols
      end

      def scopes
        @scopes ||= {}
      end

      def scope name, &block
        block ||= ->(x){ x.send(name) }
        scopes[name] = block
      end

      def sorts
        @sorts ||= {}
      end

      def sort name, &block
        block ||= ->(driver, dir){ driver.order(name => dir) }
        sorts[name.to_s] = block
      end

      # has_many :books
      # book_ids, books, book_count
      def has_many association_name
        self.attribute association_name do |record|
          record.send(association_name)
        end
        single = association_name.to_s.singularize
        self.attribute "#{single}_ids"
        self.attribute "#{single}_count" do |record|
          record.send(association_name).count
        end
      end

      # has_one :token
      # adds token
      def has_one association_name
        self.attribute association_name
        self.attribute "#{association_name}_id" do |record|
          record.send(association_name)&.id
        end
      end

      def belongs_to association_name
        self.attribute association_name
      end

      def attributes
        @attributes ||= HashWithIndifferentAccess.new
      end

      def attribute name, &block
        block ||= ->(record){ record.send(name) }
        attributes[name] = block
      end


      def permitted_params *args
        return @permitted_params || [] if args.empty?
        @permitted_params = args
      end


      def collection_actions
        @collection_actions ||= HashWithIndifferentAccess.new
      end

      def action name, &block
        collection_actions[name] = block
      end


      def member_actions
        @member_actions ||= HashWithIndifferentAccess.new
      end

      def action_for name, &block
        member_actions[name] = block
      end

    end
  end
end
