# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard (HTML)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  it "redirects to sign in when not authenticated" do
    get dashboard_path
    expect(response).to redirect_to(new_admin_session_path)
  end

  context "when signed in as admin" do
    before { sign_in admin, scope: :admin }

    it "returns 200 and chart markup" do
      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Workforce")
      expect(response.body).to include("chartHeadcountBar")
      expect(response.body).to include("chartAvgGrossBar")
      expect(response.body).to include("chartHeadcountShare")
      expect(response.body).to include("dashboard-chart-json")
      expect(response.body).to include("Filters")
    end

    it "accepts as_of, countries, and job_title_top_n params" do
      get dashboard_path, params: { as_of: "2024-03-15", countries: %w[IN], job_title_top_n: 5 }

      expect(response).to have_http_status(:ok)
    end
  end
end
