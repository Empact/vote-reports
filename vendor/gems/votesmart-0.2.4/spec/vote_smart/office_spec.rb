require File.dirname(__FILE__) + '/../spec_helper'

module VoteSmart
  describe Office do
    
    describe "all" do
      
      before :each do
        Office::Type.stub!(:all).and_return([Office::Type.new("officeTypeId" => "P"), 
                                             Office::Type.new("officeTypeId" => "C")])
      end
      
      def do_find
        Office.all
      end
      
      it_should_find :count => 19, :first => {:name => "President", :id => "1"},
                                   :last => {:name => "U.S. House", :id => "5"}
      
    end
    
    describe "find_all_by_type" do
      
      def do_find
        Office.find_all_by_type_id("P")
      end
      
      it_should_find :count => 17, :first => {:name => "President", :id => "1"},
                                   :last => {:name => "Vice President", :id => "2"}
      
    end
    
    describe "find_all_by_name" do
      
      before :each do
        Office::Type.stub!(:all).and_return([Office::Type.new("officeTypeId" => "P"), 
                                             Office::Type.new("officeTypeId" => "C"),
                                             Office::Type.new("officeTypeId" => "S")])
      end
      
      def do_find
        Office.find_all_by_name(["Secretary of State", "Attorney General"])
      end
      
      it_should_find :count => 2, :first => {:name => "Secretary of State", :id => "44"},
                                   :last => {:name => "Attorney General", :id => "12"}
    end
    
  end

  describe Office::Type do
    
    describe "all" do

      def do_find
        Office::Type.all
      end
      
      it_should_find :count => 10, :first => {:name => "Presidential and Cabinet", :id => "P"},
                                   :last => {:name => "Local Executive", :id => "M"}
      
    end
    
    describe "find_by_name" do
      
      def do_find
        Office::Type.find_by_name("State Legislature")
      end
      
      it_should_find :item => {:name => "State Legislature", :id => "L"}
      
    end

    describe "offices" do
      
      def do_find
        Office::Type.find_by_name("Presidential and Cabinet").offices
      end
      
      it_should_find :count => 17, :first => {:name => "President", :id => "1"},
                                   :last => {:name => "Vice President", :id => "2"}
      
    end
    
    describe "offices_by_name" do
      
      def do_find
        Office::Type.find_by_name("Presidential and Cabinet").offices_by_name(["President", "Vice President"])
      end
      
      it_should_find :count => 2, :first => {:name => "President", :id => "1"},
                                  :last => {:name => "Vice President", :id => "2"}
      
    end
  end
end