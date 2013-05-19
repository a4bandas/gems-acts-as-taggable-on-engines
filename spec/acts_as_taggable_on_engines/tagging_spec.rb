require 'spec_helper'

describe ActsAsTaggableOnEngines::Tagging do
  before(:each) do
    clean_database!
    @tagging = ActsAsTaggableOnEngines::Tagging.new
  end

  it "should not be valid with a invalid tag" do
    @tagging.taggable = TaggableModel.create(:name => "Bob Jones")
    @tagging.tag = ActsAsTaggableOnEngines::Tag.new(:name => "")
    @tagging.context = "tags"

    @tagging.should_not be_valid

    @tagging.errors[:tag_id].should == ["can't be blank"]
  end

  it "should not create duplicate taggings" do
    @taggable = TaggableModel.create(:name => "Bob Jones")
    @tag = ActsAsTaggableOnEngines::Tag.create(:name => "awesome")

    lambda {
      2.times { ActsAsTaggableOnEngines::Tagging.create(:taggable => @taggable, :tag => @tag, :context => 'tags') }
    }.should change(ActsAsTaggableOnEngines::Tagging, :count).by(1)
  end

end
