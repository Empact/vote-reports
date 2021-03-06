require 'rails_helper'

RSpec.describe IssuesController do
  setup :activate_authlogic

  describe "POST create" do
    let(:causes) {
      [
        create(:cause, name: 'Gun Rights'),
        create(:cause, name: 'Gun Control')
      ]
    }

    def send_request
      post :create, issue: {title: 'Guns'},
        causes: causes.map(&:to_param)
    end

    context 'as an admin', :admin do
      context 'when linking two causes' do
        it 'creates a new issue' do
          expect {
            send_request
          }.to change(Issue, :count).by(1)
        end

        it 'redirects to the new issue' do
          send_request
          expect(response).to redirect_to(issue_path(assigns[:issue]))
        end

        it 'links the issue to the selected causes' do
          send_request
          expect(assigns[:issue].causes).to match_array(causes)
        end
      end
    end

    context 'as a user' do
      before do
        login
      end
      it "denies access" do
        send_request
        expect(response).to redirect_to(root_path)
      end
    end

    context 'as a visitor' do
      it "denies access" do
        send_request
        expect(response).to redirect_to(login_path(return_to: issues_path(method: :post)))
      end
    end
  end
end
