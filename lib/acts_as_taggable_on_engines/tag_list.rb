require 'active_support/core_ext/module/delegation'

module ActsAsTaggableOnEngines
  class TagList < Array
    attr_accessor :owner

    def initialize(*args)
      add(*args)
    end

    ##
    # Returns a new TagList using the given tag string.
    #
    # Example:
    #   tag_list = TagList.from("One , Two,  Three")
    #   tag_list # ["One", "Two", "Three"]
    def self.from(string)
      string = string.join(ActsAsTaggableOnEngines.glue) if string.respond_to?(:join)

      new.tap do |tag_list|
        string = string.to_s.dup

        # Parse the quoted tags
        d = ActsAsTaggableOnEngines.delimiter
        d = d.join("|") if d.kind_of?(Array)
        string.gsub!(/(\A|#{d})\s*"(.*?)"\s*(#{d}\s*|\z)/) { tag_list << $2; $3 }
        string.gsub!(/(\A|#{d})\s*'(.*?)'\s*(#{d}\s*|\z)/) { tag_list << $2; $3 }

        tag_list.add(string.split(Regexp.new d))
      end
    end

    ##
    # Add tags to the tag_list. Duplicate or blank tags will be ignored.
    # Use the <tt>:parse</tt> option to add an unparsed tag string.
    #
    # Example:
    #   tag_list.add("Fun", "Happy")
    #   tag_list.add("Fun, Happy", :parse => true)
    def add(*names)
      extract_and_apply_options!(names)
      concat(names)
      clean!
      self
    end

    ##
    # Remove specific tags from the tag_list.
    # Use the <tt>:parse</tt> option to add an unparsed tag string.
    #
    # Example:
    #   tag_list.remove("Sad", "Lonely")
    #   tag_list.remove("Sad, Lonely", :parse => true)
    def remove(*names)
      extract_and_apply_options!(names)
      delete_if { |name| names.include?(name) }
      self
    end

    ##
    # Transform the tag_list into a tag string suitable for editing in a form.
    # The tags are joined with <tt>TagList.delimiter</tt> and quoted if necessary.
    #
    # Example:
    #   tag_list = TagList.new("Round", "Square,Cube")
    #   tag_list.to_s # 'Round, "Square,Cube"'
    def to_s
      tags = frozen? ? self.dup : self
      tags.send(:clean!)

      tags.map do |name|
        d = ActsAsTaggableOnEngines.delimiter
        d = Regexp.new d.join("|") if d.kind_of? Array
        name.index(d) ? "\"#{name}\"" : name
      end.join(ActsAsTaggableOnEngines.glue)
    end

    private

    # Remove whitespace, duplicates, and blanks.
    def clean!
      reject!(&:blank?)
      map!(&:strip)
      map!{ |tag| tag.mb_chars.downcase.to_s } if ActsAsTaggableOnEngines.force_lowercase
      map!(&:parameterize) if ActsAsTaggableOnEngines.force_parameterize

      uniq!
    end

    def extract_and_apply_options!(args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options.assert_valid_keys :parse

      if options[:parse]
        args.map! { |a| self.class.from(a) }
      end

      args.flatten!
    end
  end
end
