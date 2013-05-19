module ActsAsTaggableOnEngines::Taggable
  module Dirty
    def self.included(base)
      base.extend ActsAsTaggableOnEngines::Taggable::Dirty::ClassMethods

      base.initialize_acts_as_taggable_on_engines_dirty
    end

    module ClassMethods
      def initialize_acts_as_taggable_on_engines_dirty
        tag_types.map(&:to_s).each do |tags_type|
          tag_type         = tags_type.to_s.singularize
          context_tags     = tags_type.to_sym

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{tag_type}_list_changed?
              changed_attributes.include?("#{tag_type}_list")
            end

            def #{tag_type}_list_was
              changed_attributes.include?("#{tag_type}_list") ? changed_attributes["#{tag_type}_list"] : __send__("#{tag_type}_list")
            end

            def #{tag_type}_list_change
              [changed_attributes['#{tag_type}_list'], __send__('#{tag_type}_list')] if changed_attributes.include?("#{tag_type}_list")
            end

            def #{tag_type}_list_changes
              [changed_attributes['#{tag_type}_list'], __send__('#{tag_type}_list')] if changed_attributes.include?("#{tag_type}_list")
            end
          RUBY

        end
      end
    end
  end
end
