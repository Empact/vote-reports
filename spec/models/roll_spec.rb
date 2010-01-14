require File.dirname(__FILE__) + '/../spec_helper'

describe Roll do
  describe ".by_voted_at" do
    before do
      @recent = create_roll(:voted_at => 1.week.ago)
      @old = create_roll(:voted_at => 1.year.ago)
      @middle = create_roll(:voted_at => 3.months.ago)
    end

    it "should order by vote date, with the most recent first" do
      Roll.by_voted_at.should == [@recent, @middle, @old]
    end
  end

  describe "friendly_id" do
    it "should work" do
      roll = create_roll(:year => 1990, :number => 5, :where => 'house')
      roll.gov_track_id.should == 'h1990-5'
      Roll.find('h1990-5').should == roll
    end
  end
end