# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Salary metrics page (HTML)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  it "redirects to sign in when not authenticated" do
    get salary_metrics_path
    expect(response).to redirect_to(new_admin_session_path)
  end

  context "when signed in as admin" do
    before { sign_in admin, scope: :admin }

    it "returns 200 and shows the metrics form" do
      get salary_metrics_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Salary metrics by job title")
    end
  end
end
