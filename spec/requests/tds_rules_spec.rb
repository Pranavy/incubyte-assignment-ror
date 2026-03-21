# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TDS rules (admin)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  let(:valid_params) do
    {
      tds_rule: {
        country: "IN",
        tds_rate: "0.1",
        effective_from: "2024-01-01",
        effective_to: ""
      }
    }
  end

  describe "authentication" do
    it "redirects to sign in when accessing index while signed out" do
      get tds_rules_path
      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "when signed in as admin" do
    before { sign_in admin, scope: :admin }

    describe "GET /tds_rules" do
      it "returns 200" do
        get tds_rules_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("TDS rules")
      end
    end

    describe "GET /tds_rules/new" do
      it "returns 200" do
        get new_tds_rule_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("New TDS rule")
      end
    end

    describe "POST /tds_rules" do
      it "creates a rule and redirects with notice" do
        expect do
          post tds_rules_path, params: valid_params
        end.to change(TdsRule, :count).by(1)

        expect(response).to redirect_to(tds_rule_path(TdsRule.last))
        expect(flash[:notice]).to include("successfully created")
      end

      it "returns 422 when invalid" do
        expect do
          post tds_rules_path, params: { tds_rule: { country: "IN", tds_rate: "2", effective_from: "2024-01-01" } }
        end.not_to change(TdsRule, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "GET /tds_rules/:id" do
      it "returns 200" do
        rule = TdsRule.create!(
          country: "US",
          tds_rate: 0.12,
          effective_from: Date.new(2024, 1, 1),
          effective_to: nil
        )

        get tds_rule_path(rule)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("United States")
      end
    end

    describe "GET /tds_rules/:id/edit" do
      it "returns 200" do
        rule = TdsRule.create!(
          country: "DE",
          tds_rate: 0.05,
          effective_from: Date.new(2024, 1, 1),
          effective_to: nil
        )

        get edit_tds_rule_path(rule)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Edit TDS rule")
      end
    end

    describe "PATCH /tds_rules/:id" do
      it "updates and redirects with notice" do
        rule = TdsRule.create!(
          country: "AU",
          tds_rate: 0.05,
          effective_from: Date.new(2024, 1, 1),
          effective_to: nil
        )

        patch tds_rule_path(rule), params: {
          tds_rule: {
            country: "AU",
            tds_rate: "0.08",
            effective_from: rule.effective_from.to_s,
            effective_to: ""
          }
        }

        expect(response).to redirect_to(tds_rule_path(rule))
        expect(flash[:notice]).to include("successfully updated")
        expect(rule.reload.tds_rate).to eq(BigDecimal("0.08"))
      end

      it "returns 422 when invalid" do
        rule = TdsRule.create!(
          country: "GB",
          tds_rate: 0.05,
          effective_from: Date.new(2024, 1, 1),
          effective_to: nil
        )

        patch tds_rule_path(rule), params: {
          tds_rule: {
            country: "GB",
            tds_rate: "2",
            effective_from: rule.effective_from.to_s,
            effective_to: ""
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
