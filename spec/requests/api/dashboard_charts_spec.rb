# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API GET /api/dashboard/charts", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  let(:json_headers) { { "ACCEPT" => "application/json" } }

  it "returns 401 when not signed in" do
    get "/api/dashboard/charts", headers: json_headers
    expect(response).to have_http_status(:unauthorized)
  end

  context "when signed in as admin" do
    before { sign_in admin, scope: :admin }

    it "returns 200 with chart aggregate keys" do
      get "/api/dashboard/charts", headers: json_headers

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["as_of"]).to be_present
      expect(json["headcount_by_country"]["labels"]).to be_an(Array)
      expect(json["headcount_by_country"]["values"]).to be_an(Array)
      expect(json["avg_gross_by_country"]).to include("labels", "values")
      expect(json["avg_gross_and_net_by_country"]).to include("labels", "avg_gross", "avg_net")
      expect(json["avg_gross_by_job_title"]).to include("labels", "values", "top_n")
      expect(json["headcount_share_by_country"]).to include("labels", "values")
      expect(json["headcount_share_chart_type"]).to be_in(%w[pie bar])
      expect(json["filters"]).to include("country_codes", "job_title_top_n")
    end

    it "accepts country and job_title_top_n query params" do
      get "/api/dashboard/charts",
          params: { countries: %w[IN US], job_title_top_n: 3 },
          headers: json_headers

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["filters"]["country_codes"]).to eq(%w[IN US])
      expect(json["filters"]["job_title_top_n"]).to eq(3)
    end

    it "accepts as_of query param" do
      get "/api/dashboard/charts", params: { as_of: "2023-06-01" }, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["as_of"]).to eq("2023-06-01")
    end
  end
end
