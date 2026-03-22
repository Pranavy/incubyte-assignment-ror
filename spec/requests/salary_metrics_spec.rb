# frozen_string_literal: true

require "rails_helper"

# Salary metrics API: gross salary is Employee#salary (annual gross).
# Net salary per employee is gross * (1 - rate). Rate comes from TdsRule when one applies for
# the reference date; otherwise defaults are IN 10%, US 12%, other countries 0%.
RSpec.describe "Salary metrics API (by job title)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  let!(:job_title) { JobTitle.create!(title: "Senior Developer") }
  let!(:other_title) { JobTitle.create!(title: "Other") }

  let(:json_headers) { { "ACCEPT" => "application/json" } }

  describe "GET /api/salary_metrics/by_job_title" do
    context "when not signed in as admin" do
      it "does not return salary metrics (requires authentication)" do
        get "/api/salary_metrics/by_job_title", params: { job_title_id: job_title.id }, headers: json_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in as admin" do
      before { sign_in admin, scope: :admin }

      it "returns 404 when job_title_id does not exist" do
        get "/api/salary_metrics/by_job_title", params: { job_title_id: 9_999_999 }, headers: json_headers

        expect(response).to have_http_status(:not_found)
      end

      it "returns 200 with null averages when the job title exists but has no employees" do
        get "/api/salary_metrics/by_job_title", params: { job_title_id: job_title.id }, headers: json_headers

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("application/json")

        json = response.parsed_body
        expect(json["job_title_id"]).to eq(job_title.id)
        expect(json["job_title"]).to eq("Senior Developer")
        expect(json).to have_key("avg_gross_salary")
        expect(json).to have_key("avg_net_salary")
        expect(json["avg_gross_salary"]).to be_nil
        expect(json["avg_net_salary"]).to be_nil
      end

      it "returns average gross and net salaries for all employees with that job title" do
        TdsRule.create!(country: "IN", tds_rate: BigDecimal("0.10"), effective_from: Date.new(2020, 1, 1))
        TdsRule.create!(country: "US", tds_rate: BigDecimal("0.12"), effective_from: Date.new(2020, 1, 1))

        Employee.create!(
          first_name: "A",
          last_name: "One",
          country: "IN",
          job_title: job_title,
          salary: BigDecimal("100000.00")
        )
        Employee.create!(
          first_name: "B",
          last_name: "Two",
          country: "US",
          job_title: job_title,
          salary: BigDecimal("200000.00")
        )

        get "/api/salary_metrics/by_job_title", params: { job_title_id: job_title.id }, headers: json_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json["job_title_id"]).to eq(job_title.id)
        expect(json["job_title"]).to eq("Senior Developer")

        # Avg gross = (100_000 + 200_000) / 2 = 150_000
        expect(json["avg_gross_salary"]).to eq(150_000.0)

        # Net: IN 90_000 + US 176_000 => avg 133_000
        expect(json["avg_net_salary"]).to eq(133_000.0)
      end

      it "ignores employees with other job titles" do
        TdsRule.create!(country: "GB", tds_rate: BigDecimal("0"), effective_from: Date.new(2020, 1, 1))

        Employee.create!(
          first_name: "X",
          last_name: "Included",
          country: "GB",
          job_title: job_title,
          salary: BigDecimal("80000.00")
        )
        Employee.create!(
          first_name: "Y",
          last_name: "Excluded",
          country: "GB",
          job_title: other_title,
          salary: BigDecimal("999999.00")
        )

        get "/api/salary_metrics/by_job_title", params: { job_title_id: job_title.id }, headers: json_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["avg_gross_salary"]).to eq(80_000.0)
        expect(json["avg_net_salary"]).to eq(80_000.0)
      end

      it "uses default 0% for countries other than IN/US when no TDS rule exists" do
        Employee.create!(
          first_name: "No",
          last_name: "Rule",
          country: "AU",
          job_title: job_title,
          salary: BigDecimal("50000.00")
        )

        get "/api/salary_metrics/by_job_title", params: { job_title_id: job_title.id }, headers: json_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["avg_gross_salary"]).to eq(50_000.0)
        expect(json["avg_net_salary"]).to eq(50_000.0)
      end

      it "uses default 10% for India when no TDS rule exists in the database" do
        Employee.create!(
          first_name: "India",
          last_name: "Default",
          country: "IN",
          job_title: job_title,
          salary: BigDecimal("100000.00")
        )

        get "/api/salary_metrics/by_job_title", params: { job_title_id: job_title.id }, headers: json_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["avg_gross_salary"]).to eq(100_000.0)
        expect(json["avg_net_salary"]).to eq(90_000.0)
      end
    end
  end
end
