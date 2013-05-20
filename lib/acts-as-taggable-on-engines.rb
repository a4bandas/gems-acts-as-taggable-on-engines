require "active_record"
require "active_record/version"
require "action_view"

require "digest/sha1"

$LOAD_PATH.unshift(File.dirname(__FILE__))

module ActsAsTaggableOnEngines
  mattr_accessor :delimiter
  @@delimiter = ','

  mattr_accessor :force_lowercase
  @@force_lowercase = false

  mattr_accessor :force_parameterize
  @@force_parameterize = false

  mattr_accessor :strict_case_match
  @@strict_case_match = false

  mattr_accessor :remove_unused_tags
  self.remove_unused_tags = false

  def self.glue
    delimiter = @@delimiter.kind_of?(Array) ? @@delimiter[0] : @@delimiter
    delimiter.ends_with?(" ") ? delimiter : "#{delimiter} "
  end

  def self.setup
    yield self
  end
end


require "acts_as_taggable_on_engines/utils"

require "acts_as_taggable_on_engines/taggable"
require "acts_as_taggable_on_engines/acts_as_taggable_on_engines/compatibility"
require "acts_as_taggable_on_engines/acts_as_taggable_on_engines/core"
require "acts_as_taggable_on_engines/acts_as_taggable_on_engines/collection"
require "acts_as_taggable_on_engines/acts_as_taggable_on_engines/cache"
require "acts_as_taggable_on_engines/acts_as_taggable_on_engines/ownership"
require "acts_as_taggable_on_engines/acts_as_taggable_on_engines/related"
require "acts_as_taggable_on_engines/acts_as_taggable_on_engines/dirty"

require "acts_as_taggable_on_engines/tagger"
require "acts_as_taggable_on_engines/tag"
require "acts_as_taggable_on_engines/tag_list"
require "acts_as_taggable_on_engines/tags_helper"
require "acts_as_taggable_on_engines/tagging"

$LOAD_PATH.shift


if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend ActsAsTaggableOnEngines::Compatibility
  ActiveRecord::Base.extend ActsAsTaggableOnEngines::Taggable
  ActiveRecord::Base.send :include, ActsAsTaggableOnEngines::Tagger
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, ActsAsTaggableOnEngines::TagsHelper
end

