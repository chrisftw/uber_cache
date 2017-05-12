require './spec/spec_helper'
require './lib/uber_cache'

describe UberCache do
  before do
    @cache = UberCache.new("test-cache", "localhost:11211")
  end
  
  describe "cache" do
    describe "read/write" do
      it "should write then read the cache" do
        @cache.write("key", "value")
        val = @cache.read("key")
        val.should == "value"
      end

      it "should write with a block then read the cache" do
        @cache.write("key"){ temp = "decoy"; "one " + "two " + "three" }
        val = @cache.read("key")
        val.should == "one two three"
      end

      it "should remove cache after ttl runs out" do
        @cache.write("key2", "value2", {:ttl => 1})
        val = @cache.read("key2")
        val.should == "value2"
        sleep 1
        val = @cache.read("key2")
        val.should == nil
      end
    end

    describe "read_or_write" do
      it "should read_or_write to/from the cache" do
        first_val = @cache.read_or_write("key3"){"value" + " X"}
        first_val.should == "value X"
        val = @cache.read("key3")
        val.should == "value X"
        @cache.read_or_write("key3"){"value" + " Y"}
        val = @cache.read("key3")
        val.should == "value X"
      end
    end

    describe "clear" do
      it "should clear values for specific keys" do
        @cache.write("key4", "value4")
        @cache.write("key5", "value5")
        val = @cache.read("key4")
        val.should == "value4"
        val = @cache.read("key5")
        val.should == "value5"
        @cache.clear("key4")
        val = @cache.read("key4")
        val.should == nil
        val = @cache.read("key5")
        val.should == "value5"
      end
    end

    describe "clear_all" do
      it "should clear values for specific keys" do
        @cache.write("key4", "value4")
        @cache.write("key5", "value5")
        val = @cache.read("key4")
        val.should == "value4"
        val = @cache.read("key5")
        val.should == "value5"
        @cache.clear_all
        val = @cache.read("key4")
        val.should == nil
        val = @cache.read("key5")
        val.should == nil
      end
    end
  end
  
  describe "Objects in Cache" do
    describe "read/write" do
      before do
        class Person
          attr_accessor :first_name, :last_name, :birthday, :life_story
        end
      end
      
      
      it "should write then read the cache" do
        @cache.obj_write("key", "value")
        val = @cache.obj_read("key")
        val.should == "value"
      end
      
      it "should write objects to the cahce then read the objects from cache" do
        @cache_this = Person.new
        @cache_this.first_name = "Robert"
        @cache_this.last_name = "Paulson"
        @cache_this.birthday = Date.new(1947, 9, 27)
        
        @cache.obj_write("bob", @cache_this)
        val = @cache.obj_read("bob")
        val.first_name.should == "Robert"
        val.last_name.should == "Paulson"
        val.birthday.day.should == 27
        val.class.should == Person
      end

      it "should write with a block then read the cache" do
        @cache.obj_write("key"){ temp = "decoy"; "one " + "two " + "three" }
        val = @cache.obj_read("key")
        val.should == "one two three"
      end

      it "should remove cache after ttl runs out" do
        @cache.obj_write("key2", "value2", {:ttl => 1})
        val = @cache.obj_read("key2")
        val.should == "value2"
        sleep 1.5
        val = @cache.obj_read("key2")
        val.should == nil
      end
    end

    describe "read_or_write" do
      it "should read_or_write to/from the cache" do
        first_val = @cache.obj_read_or_write("key3"){"value" + " X"}
        first_val.should == "value X"
        val = @cache.obj_read("key3")
        val.should == "value X"
        @cache.obj_read_or_write("key3"){"value" + " Y"}
        val = @cache.obj_read("key3")
        val.should == "value X"
      end
      
      it "should reload if :reload option is true otherwise normal behavior" do
        first_val = @cache.obj_read_or_write("turkey"){"value" + " ABC"}
        first_val.should == "value ABC"
        val = @cache.obj_read("turkey")
        val.should == "value ABC"
        
        second_val = @cache.obj_read_or_write("turkey"){"value" + " XYZ"}
        second_val.should == "value ABC"
      end
    end

    describe "clear" do
      it "should clear values for specific keys" do
        @cache.obj_write("key4", "value4")
        @cache.obj_write("key5", "value5")
        val = @cache.obj_read("key4")
        val.should == "value4"
        val = @cache.obj_read("key5")
        val.should == "value5"
        @cache.obj_clear("key4")
        val = @cache.obj_read("key4")
        val.should == nil
        val = @cache.obj_read("key5")
        val.should == "value5"
      end
    end
    
    describe "bite size data" do
      it "break big objects down to smaller segments and cache them on write, then rebuild the object on read." do
        people = [Person.new,Person.new]
        people[0].first_name = "Tyler"
        people[0].last_name = "Durden"
        people[0].birthday = Date.new(1963, 12, 18)
        people[0].life_story = "All the ways you wish you could be, that's me. I look like you wanna look, I kiss like you wanna kiss, I am smart, capable, and most importantly, I am free in all the ways that you are not."
        people[1].first_name = "Marla"
        people[1].last_name = "Singer"
        people[1].birthday = Date.new(1966, 5, 26)
        people[1].life_story = "Marla Singer was a strong-willed woman who came across as being a complete nutcase. She used to steal food from delivery vans and clothing from laundromats to survive. She once attempted suicide by swallowing a bottle of Xanax, but it was \"probably one of those cry-for-help things.\""
        
        @cache.obj_write("two-people", people, :max_size => 80)
        segment0 = @cache.read("two-people-0")
        segment0.size.should == 80
        segment0.include?("Person").should == true
        segment1 = @cache.read("two-people-1")
        segment1.size.should == 80
        segment1[0..2].should == "ate"
        segment1[-36..-1].should == "All the ways you wish you could be, "
        segment8 = @cache.read("two-people-8")
        segment8.include?("cry-for-help").should == true
        segment9 = @cache.read("two-people-9")
        segment9.should == nil
        cached_obj = @cache.obj_read("two-people")
        cached_obj.length.should == 2
        cached_obj[0].first_name.should == "Tyler"
        cached_obj[1].first_name.should == "Marla"
      end
    end
  end
end
