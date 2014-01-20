module ActsAsTaggableOnEngines
  module Taggable
    def taggable?
      false
    end

    ##
    # This is an alias for calling <tt>acts_as_taggable_on_engines :tags</tt>.
    #
    # Example:
    #   class Book < ActiveRecord::Base
    #     acts_as_taggable
    #   end
    def acts_as_taggable_on_engines
      acts_as_taggable_on_engines :tags
    end

    ##
    # This is an alias for calling <tt>acts_as_ordered_taggable_on :tags</tt>.
    #
    # Example:
    #   class Book < ActiveRecord::Base
    #     acts_as_ordered_taggable
    #   end
    def acts_as_ordered_taggable_on_engines
      acts_as_ordered_taggable_on :tags
    end

    ##
    # Make a model taggable on specified contexts.
    #
    # @param [Array] tag_types An array of taggable contexts
    #
    # Example:
    #   class User < ActiveRecord::Base
    #     acts_as_taggable_on_engines :languages, :skills
    #   end
    def acts_as_taggable_on_engines(*tag_types)
      taggable_on(false, tag_types)
    end


    ##
    # Make a model taggable on specified contexts
    # and preserves the order in which tags are created
    #
    # @param [Array] tag_types An array of taggable contexts
    #
    # Example:
    #   class User < ActiveRecord::Base
    #     acts_as_ordered_taggable_on :languages, :skills
    #   end
    def acts_as_ordered_taggable_on_engines(*tag_types)
      taggable_on(true, tag_types)
    end

    private

      # Make a model taggable on specified contexts
      # and optionally preserves the order in which tags are created
      #
      # Seperate methods used above for backwards compatibility
      # so that the original acts_as_taggable_on_engines method is unaffected
      # as it's not possible to add another arguement to the method
      # without the tag_types being enclosed in square brackets
      #
      # NB: method overridden in core module in order to create tag type
      #     associations and methods after this logic has executed
      #
      def taggable_on_engines(preserve_tag_order, *tag_types)
        tag_types = tag_types.to_a.flatten.compact.map(&:to_sym)

        if taggable?
          self.tag_types = (self.tag_types + tag_types).uniq
          self.preserve_tag_order = preserve_tag_order
        else
          class_attribute :tag_types
          self.tag_types = tag_types
          class_attribute :preserve_tag_order
          self.preserve_tag_order = preserve_tag_order

          class_eval do
            has_many :taggings, :as => :taggable, :dependent => :destroy, :class_name => "ActsAsTaggableOnEngines::Tagging"
            has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOnEngines::Tag"

            def self.taggable?
              true
            end

            include ActsAsTaggableOnEngines::Utils
          end
        end

        # each of these add context-specific methods and must be
        # called on each call of taggable_on
        include ActsAsTaggableOnEngines::Taggable::Core
        include ActsAsTaggableOnEngines::Taggable::Collection
        include ActsAsTaggableOnEngines::Taggable::Cache
        include ActsAsTaggableOnEngines::Taggable::Ownership
        include ActsAsTaggableOnEngines::Taggable::Related
        include ActsAsTaggableOnEngines::Taggable::Dirty
      end

  end
end
