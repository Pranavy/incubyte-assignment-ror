# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin authentication (Devise)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  describe "GET /admins/sign_in" do
    it "renders the login form" do
      get new_admin_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Log in")
    end
  end

  describe "POST /admins/sign_in" do
    it "redirects to root and shows signed-in UI when credentials are valid" do
      post admin_session_path, params: { admin: { email: admin.email, password: password, remember_me: "0" } }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Sign out")
    end

    it "re-renders sign in when the password is wrong" do
      post admin_session_path, params: { admin: { email: admin.email, password: "wrong-password", remember_me: "0" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /admins/sign_up" do
    it "renders the registration form" do
      get new_admin_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign up")
    end
  end

  describe "POST /admins (registration)" do
    it "creates an admin and redirects to the configured after-sign-up path" do
      expect do
        post admin_registration_path, params: {
          admin: {
            email: "new-admin@example.com",
            password: password,
            password_confirmation: password
          }
        }
      end.to change(Admin, :count).by(1)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /admins/sign_out" do
    it "signs out and shows signed-out UI" do
      sign_in admin, scope: :admin

      delete destroy_admin_session_path

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Sign in")
    end
  end

  describe "GET /admins/edit" do
    it "redirects to sign in when not authenticated" do
      get edit_admin_registration_path

      expect(response).to redirect_to(new_admin_session_path)
    end

    it "renders the account edit form when signed in" do
      sign_in admin, scope: :admin

      get edit_admin_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit account")
    end
  end
end
