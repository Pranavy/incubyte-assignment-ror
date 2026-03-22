# frozen_string_literal: true

require "rails_helper"

# Gross: Employee#salary. Net: gross × (1 − TDS rate) per employee for the reference date
# (DB rule or defaults: IN 10%, US 12%, else 0%).
RSpec.describe "Salary metrics API (by country)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  let!(:job_title) { JobTitle.create!(title: "Engineer") }

  let(:json_headers) { { "ACCEPT" => "application/json" } }

  describe "GET /api/salary_metrics/by_country" do
    context "when not signed in as admin" do
      it "returns unauthorized" do
        get "/api/salary_metrics/by_country", params: { country: "IN" }, headers: json_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as admin" do
      before { sign_in admin, scope: :admin }

      it "returns 422 when country is missing" do
        get "/api/salary_metrics/by_country", headers: json_headers

        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json["error"]).to be_present
      end

      it "returns 422 when country is not an allowed code" do
        get "/api/salary_metrics/by_country", params: { country: "ZZ" }, headers: json_headers

        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json["error"]).to be_present
      end

      it "returns 200 with null aggregates when the country is valid but has no employees" do
        get "/api/salary_metrics/by_country", params: { country: "DE" }, headers: json_headers

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("application/json")

        json = response.parsed_body
        expect(json["country"]).to eq("DE")
        %w[
          min_gross_salary max_gross_salary avg_gross_salary
          min_net_salary max_net_salary avg_net_salary
        ].each do |key|
          expect(json).to have_key(key)
          expect(json[key]).to be_nil
        end
      end

      it "returns min, max, and average gross and net for employees in that country" do
        TdsRule.create!(country: "IN", tds_rate: BigDecimal("0.10"), effective_from: Date.new(2020, 1, 1))

        Employee.create!(
          first_name: "A",
          last_name: "Low",
          country: "IN",
          job_title: job_title,
          salary: BigDecimal("100000.00")
        )
        Employee.create!(
          first_name: "B",
          last_name: "High",
          country: "IN",
          job_title: job_title,
          salary: BigDecimal("200000.00")
        )

        get "/api/salary_metrics/by_country",
            params: { country: "IN", as_of: "2024-06-15" },
            headers: json_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json["country"]).to eq("IN")

        expect(json["min_gross_salary"]).to eq(100_000.0)
        expect(json["max_gross_salary"]).to eq(200_000.0)
        expect(json["avg_gross_salary"]).to eq(150_000.0)

        # Net at 10%: 90_000 and 180_000
        expect(json["min_net_salary"]).to eq(90_000.0)
        expect(json["max_net_salary"]).to eq(180_000.0)
        expect(json["avg_net_salary"]).to eq(135_000.0)
      end

      it "normalizes country param to uppercase in the response" do
        Employee.create!(
          first_name: "X",
          last_name: "Y",
          country: "US",
          job_title: job_title,
          salary: BigDecimal("50000.00")
        )

        get "/api/salary_metrics/by_country", params: { country: "us" }, headers: json_headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["country"]).to eq("US")
      end

      it "uses default TDS for the country when no rule exists (US 12%)" do
        Employee.create!(
          first_name: "Solo",
          last_name: "Us",
          country: "US",
          job_title: job_title,
          salary: BigDecimal("100000.00")
        )

        get "/api/salary_metrics/by_country", params: { country: "US" }, headers: json_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json["min_gross_salary"]).to eq(100_000.0)
        expect(json["max_gross_salary"]).to eq(100_000.0)
        expect(json["avg_gross_salary"]).to eq(100_000.0)
        expect(json["min_net_salary"]).to eq(88_000.0)
        expect(json["max_net_salary"]).to eq(88_000.0)
        expect(json["avg_net_salary"]).to eq(88_000.0)
      end
    end
  end
end
