module ActsAsTaggableOnEngines::Taggable
  module Related
    def self.included(base)
      base.send :include, ActsAsTaggableOnEngines::Taggable::Related::InstanceMethods
      base.extend ActsAsTaggableOnEngines::Taggable::Related::ClassMethods
      base.initialize_acts_as_taggable_on_engines_related
    end

    module ClassMethods
      def initialize_acts_as_taggable_on_engines_related
        tag_types.map(&:to_s).each do |tag_type|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def find_related_#{tag_type}(options = {})
              related_tags_for('#{tag_type}', self.class, options)
            end
            alias_method :find_related_on_#{tag_type}, :find_related_#{tag_type}

            def find_related_#{tag_type}_for(klass, options = {})
              related_tags_for('#{tag_type}', klass, options)
            end
          RUBY
        end

        unless tag_types.empty?
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def find_matching_contexts(search_context, result_context, options = {})
              matching_contexts_for(search_context.to_s, result_context.to_s, self.class, options)
            end

            def find_matching_contexts_for(klass, search_context, result_context, options = {})
              matching_contexts_for(search_context.to_s, result_context.to_s, klass, options)
            end
          RUBY
        end
      end

      def acts_as_taggable_on_engines(*args)
        super(*args)
        initialize_acts_as_taggable_on_engines_related
      end
    end

    module InstanceMethods
      def matching_contexts_for(search_context, result_context, klass, options = {})
        tags_to_find = tags_on(search_context).collect { |t| t.name }

        klass.select("#{klass.table_name}.*, COUNT(#{ActsAsTaggableOnEngines::Tag.table_name}.#{ActsAsTaggableOnEngines::Tag.primary_key}) AS count") \
             .from("#{klass.table_name}, #{ActsAsTaggableOnEngines::Tag.table_name}, #{ActsAsTaggableOnEngines::Tagging.table_name}") \
             .where(["#{exclude_self(klass, id)} #{klass.table_name}.#{klass.primary_key} = #{ActsAsTaggableOnEngines::Tagging.table_name}.taggable_id AND #{ActsAsTaggableOnEngines::Tagging.table_name}.taggable_type = '#{klass.base_class.to_s}' AND #{ActsAsTaggableOnEngines::Tagging.table_name}.tag_id = #{ActsAsTaggableOnEngines::Tag.table_name}.#{ActsAsTaggableOnEngines::Tag.primary_key} AND #{ActsAsTaggableOnEngines::Tag.table_name}.name IN (?) AND #{ActsAsTaggableOnEngines::Tagging.table_name}.context = ?", tags_to_find, result_context]) \
             .group(group_columns(klass)) \
             .order("count DESC")
      end

      def related_tags_for(context, klass, options = {})
				tags_to_ignore = Array.wrap(options.delete(:ignore)).map(&:to_s) || []
        tags_to_find = tags_on(context).collect { |t| t.name }.reject { |t| tags_to_ignore.include? t }

        klass.select("#{klass.table_name}.*, COUNT(#{ActsAsTaggableOnEngines::Tag.table_name}.#{ActsAsTaggableOnEngines::Tag.primary_key}) AS count") \
             .from("#{klass.table_name}, #{ActsAsTaggableOnEngines::Tag.table_name}, #{ActsAsTaggableOnEngines::Tagging.table_name}") \
             .where(["#{exclude_self(klass, id)} #{klass.table_name}.#{klass.primary_key} = #{ActsAsTaggableOnEngines::Tagging.table_name}.taggable_id AND #{ActsAsTaggableOnEngines::Tagging.table_name}.taggable_type = '#{klass.base_class.to_s}' AND #{ActsAsTaggableOnEngines::Tagging.table_name}.tag_id = #{ActsAsTaggableOnEngines::Tag.table_name}.#{ActsAsTaggableOnEngines::Tag.primary_key} AND #{ActsAsTaggableOnEngines::Tag.table_name}.name IN (?)", tags_to_find]) \
             .group(group_columns(klass)) \
             .order("count DESC")
      end

      private

      def exclude_self(klass, id)
        if [self.class.base_class, self.class].include? klass
          "#{klass.table_name}.#{klass.primary_key} != #{id} AND"
        else
          nil
        end
      end

      def group_columns(klass)
        if ActsAsTaggableOnEngines::Tag.using_postgresql?
          grouped_column_names_for(klass)
        else
          "#{klass.table_name}.#{klass.primary_key}"
        end
      end
    end
  end
end
