require 'rails_helper'

RSpec.describe Politicians::CausesController do
  describe 'GET index' do
    let(:politician) { create(:politician) }
    let(:cause) { create(:cause) }
    let!(:report_score) { create(:report_score, report: cause.report) }

    def send_request
      get :index, politician_id: politician
    end

    context 'with format html' do
      let(:format) { :html }

      it 'succeeds' do
        send_request
        expect(response).to be_success
      end
    end

    context 'with format js' do
      let(:format) { :js }

      def send_request
        xhr :get, :index, politician_id: politician
      end

      it 'succeeds' do
        send_request
        expect(response).to be_success
      end
    end
  end
end
