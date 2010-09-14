require File.dirname(__FILE__) + '/../../spec_helper'
 
describe Politicians::ReportsController do
  integrate_views

  before do
    @politician = create_politician
    @report_scores = 5.times.map do
      create_published_report.scores.for_politicians(@politician).first
    end
  end

  describe "GET index" do
    it "should return reports" do
      get :index, :politician_id => @politician

      response.should be_success

      assigns[:politician].should == @politician
      assigns[:scores].to_a.should =~ @report_scores
    end

    context "when narrowed by subject" do
      before do
        @score = @report_scores.first
        @report_subject = create_report_subject(:report => @score.report)
      end

      it "should return reports with those subjects" do
        get :index, :politician_id => @politician, :subjects => [@report_subject.subject.to_param]

        response.should be_success

        assigns[:politician].should == @politician
        assigns[:scores].to_a.should == [@score]
      end
    end
  end
end