# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Salary metrics pages (HTML)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  it "redirects /salary_metrics to the job title metrics page" do
    get "/salary_metrics"
    expect(response).to redirect_to(salary_metrics_job_title_path)
  end

  it "redirects to sign in when not authenticated (job title page)" do
    get salary_metrics_job_title_path
    expect(response).to redirect_to(new_admin_session_path)
  end

  it "redirects to sign in when not authenticated (country page)" do
    get salary_metrics_country_path
    expect(response).to redirect_to(new_admin_session_path)
  end

  context "when signed in as admin" do
    before { sign_in admin, scope: :admin }

    it "returns 200 on the job title metrics page" do
      get salary_metrics_job_title_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Salary metrics by job title")
    end

    it "returns 200 on the country metrics page" do
      get salary_metrics_country_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Salary metrics by country")
    end
  end
end
