# encoding: utf-8
require 'spec_helper'

describe ActsAsTaggableOnEngines::Tag do
  before(:each) do
    clean_database!
    @tag = ActsAsTaggableOnEngines::Tag.new
    @user = TaggableModel.create(:name => "Pablo")
  end

  describe "named like any" do
    before(:each) do
      ActsAsTaggableOnEngines::Tag.create(:name => "Awesome")
      ActsAsTaggableOnEngines::Tag.create(:name => "awesome")
      ActsAsTaggableOnEngines::Tag.create(:name => "epic")
    end

    it "should find both tags" do
      ActsAsTaggableOnEngines::Tag.named_like_any(["awesome", "epic"]).should have(3).items
    end
  end

  describe "find or create by name" do
    before(:each) do
      @tag.name = "awesome"
      @tag.save
    end

    it "should find by name" do
      ActsAsTaggableOnEngines::Tag.find_or_create_with_like_by_name("awesome").should == @tag
    end

    it "should find by name case insensitive" do
      ActsAsTaggableOnEngines::Tag.find_or_create_with_like_by_name("AWESOME").should == @tag
    end

    it "should create by name" do
      lambda {
        ActsAsTaggableOnEngines::Tag.find_or_create_with_like_by_name("epic")
      }.should change(ActsAsTaggableOnEngines::Tag, :count).by(1)
    end
  end

  unless ActsAsTaggableOnEngines::Tag.using_sqlite?
    describe "find or create by unicode name" do
      before(:each) do
        @tag.name = "привет"
        @tag.save
      end

      it "should find by name" do
        ActsAsTaggableOnEngines::Tag.find_or_create_with_like_by_name("привет").should == @tag
      end

      it "should find by name case insensitive" do
        ActsAsTaggableOnEngines::Tag.find_or_create_with_like_by_name("ПРИВЕТ").should == @tag
      end
    end
  end

  describe "find or create all by any name" do
    before(:each) do
      @tag.name = "awesome"
      @tag.save
    end

    it "should find by name" do
      ActsAsTaggableOnEngines::Tag.find_or_create_all_with_like_by_name("awesome").should == [@tag]
    end

    it "should find by name case insensitive" do
      ActsAsTaggableOnEngines::Tag.find_or_create_all_with_like_by_name("AWESOME").should == [@tag]
    end

    it "should create by name" do
      lambda {
        ActsAsTaggableOnEngines::Tag.find_or_create_all_with_like_by_name("epic")
      }.should change(ActsAsTaggableOnEngines::Tag, :count).by(1)
    end

    it "should find or create by name" do
      lambda {
        ActsAsTaggableOnEngines::Tag.find_or_create_all_with_like_by_name("awesome", "epic").map(&:name).should == ["awesome", "epic"]
      }.should change(ActsAsTaggableOnEngines::Tag, :count).by(1)
    end

    it "should return an empty array if no tags are specified" do
      ActsAsTaggableOnEngines::Tag.find_or_create_all_with_like_by_name([]).should == []
    end
  end

  it "should require a name" do
    @tag.valid?

    @tag.errors[:name].should == ["can't be blank"]

    @tag.name = "something"
    @tag.valid?

    @tag.errors[:name].should == []
  end

  it "should limit the name length to 255 or less characters" do
    @tag.name = "fgkgnkkgjymkypbuozmwwghblmzpqfsgjasflblywhgkwndnkzeifalfcpeaeqychjuuowlacmuidnnrkprgpcpybarbkrmziqihcrxirlokhnzfvmtzixgvhlxzncyywficpraxfnjptxxhkqmvicbcdcynkjvziefqzyndxkjmsjlvyvbwraklbalykyxoliqdlreeykuphdtmzfdwpphmrqvwvqffojkqhlzvinqajsxbszyvrqqyzusxranr"
    @tag.valid?
    @tag.errors[:name].should == ["is too long (maximum is 255 characters)"]

    @tag.name = "fgkgnkkgjymkypbuozmwwghblmzpqfsgjasflblywhgkwndnkzeifalfcpeaeqychjuuowlacmuidnnrkprgpcpybarbkrmziqihcrxirlokhnzfvmtzixgvhlxzncyywficpraxfnjptxxhkqmvicbcdcynkjvziefqzyndxkjmsjlvyvbwraklbalykyxoliqdlreeykuphdtmzfdwpphmrqvwvqffojkqhlzvinqajsxbszyvrqqyzusxran"
    @tag.valid?
    @tag.errors[:name].should == []
  end

  it "should equal a tag with the same name" do
    @tag.name = "awesome"
    new_tag = ActsAsTaggableOnEngines::Tag.new(:name => "awesome")
    new_tag.should == @tag
  end

  it "should return its name when to_s is called" do
    @tag.name = "cool"
    @tag.to_s.should == "cool"
  end

  it "have named_scope named(something)" do
    @tag.name = "cool"
    @tag.save!
    ActsAsTaggableOnEngines::Tag.named('cool').should include(@tag)
  end

  it "have named_scope named_like(something)" do
    @tag.name = "cool"
    @tag.save!
    @another_tag = ActsAsTaggableOnEngines::Tag.create!(:name => "coolip")
    ActsAsTaggableOnEngines::Tag.named_like('cool').should include(@tag, @another_tag)
  end

  describe "escape wildcard symbols in like requests" do
    before(:each) do
      @tag.name = "cool"
      @tag.save
      @another_tag = ActsAsTaggableOnEngines::Tag.create!(:name => "coo%")
      @another_tag2 = ActsAsTaggableOnEngines::Tag.create!(:name => "coolish")
    end

    it "return escaped result when '%' char present in tag" do
        ActsAsTaggableOnEngines::Tag.named_like('coo%').should_not include(@tag)
        ActsAsTaggableOnEngines::Tag.named_like('coo%').should include(@another_tag)
    end

  end

  describe "when using strict_case_match" do
    before do
      ActsAsTaggableOnEngines.strict_case_match = true
      @tag.name = "awesome"
      @tag.save!
    end

    after do
      ActsAsTaggableOnEngines.strict_case_match = false
    end

    it "should find by name" do
      ActsAsTaggableOnEngines::Tag.find_or_create_with_like_by_name("awesome").should == @tag
    end

    it "should find by name case sensitively" do
      expect {
        ActsAsTaggableOnEngines::Tag.find_or_create_with_like_by_name("AWESOME")
      }.to change(ActsAsTaggableOnEngines::Tag, :count)

      ActsAsTaggableOnEngines::Tag.last.name.should == "AWESOME"
    end

    it "should have a named_scope named(something) that matches exactly" do
      uppercase_tag = ActsAsTaggableOnEngines::Tag.create(:name => "Cool")
      @tag.name     = "cool"
      @tag.save!

      ActsAsTaggableOnEngines::Tag.named('cool').should include(@tag)
      ActsAsTaggableOnEngines::Tag.named('cool').should_not include(uppercase_tag)
    end
  end

  describe "name uniqeness validation" do
    let(:duplicate_tag) { ActsAsTaggableOnEngines::Tag.new(:name => 'ror') }

    before { ActsAsTaggableOnEngines::Tag.create(:name => 'ror') }

    context "when don't need unique names" do
      it "should not run uniqueness validation" do
        duplicate_tag.stub(:validates_name_uniqueness?).and_return(false)
        duplicate_tag.save
        duplicate_tag.should be_persisted
      end
    end

    context "when do need unique names" do
      it "should run uniqueness validation" do
        duplicate_tag.should_not be_valid
      end

      it "add error to name" do
        duplicate_tag.save

        duplicate_tag.should have(1).errors
        duplicate_tag.errors.messages[:name].should include('has already been taken')
      end
    end
  end
end
