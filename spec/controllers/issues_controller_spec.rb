require 'spec_helper'

describe IssuesController do
  setup :activate_authlogic

  describe "POST create" do
    context 'as an admin' do
      let(:admin) { create_admin }

      before do
        login admin
      end

      context 'when linking two causes' do
        before do
          @causes = [
            create_cause(name: 'Gun Rights'),
            create_cause(name: 'Gun Control')
          ]
        end

        def send_request
          post :create, issue: {title: 'Guns'},
            causes: @causes.map(&:to_param)
        end

        it 'creates a new issue' do
          expect {
            send_request
          }.to change(Issue, :count).by(1)
        end

        it 'redirects to the new issue' do
          send_request
          response.should redirect_to(issue_path(assigns[:issue]))
        end

        it 'links the issue to the selected causes' do
          send_request
          assigns[:issue].causes.should =~ @causes
        end
      end
    end

    context 'as a user' do
      before do
        login
      end
      it "denies access" do
        post :create
        response.should redirect_to(root_path)
      end
    end

    context 'as a visitor' do
      it "denies access" do
        post :create
        response.should redirect_to(login_path(return_to: issues_path(method: :post)))
      end
    end
  end
end
