require 'spec_helper'

describe ActsAsTaggableOnEngines::TagsHelper do
  before(:each) do
    clean_database!

    @bob = TaggableModel.create(:name => "Bob Jones",  :language_list => "ruby, php")
    @tom = TaggableModel.create(:name => "Tom Marley", :language_list => "ruby, java")
    @eve = TaggableModel.create(:name => "Eve Nodd",   :language_list => "ruby, c++")

    @helper = class Helper
      include ActsAsTaggableOnEngines::TagsHelper
    end.new
  end

  it "should yield the proper css classes" do
    tags = { }

    @helper.tag_cloud(TaggableModel.tag_counts_on(:languages), ["sucky", "awesome"]) do |tag, css_class|
      tags[tag.name] = css_class
    end

    tags["ruby"].should == "awesome"
    tags["java"].should == "sucky"
    tags["c++"].should == "sucky"
    tags["php"].should == "sucky"
  end

  it "should handle tags with zero counts (build for empty)" do
    bob = ActsAsTaggableOnEngines::Tag.create(:name => "php")
    tom = ActsAsTaggableOnEngines::Tag.create(:name => "java")
    eve = ActsAsTaggableOnEngines::Tag.create(:name => "c++")

    tags = { }

    @helper.tag_cloud(ActsAsTaggableOnEngines::Tag.all, ["sucky", "awesome"]) do |tag, css_class|
      tags[tag.name] = css_class
    end

    tags["java"].should == "sucky"
    tags["c++"].should == "sucky"
    tags["php"].should == "sucky"
  end
end
