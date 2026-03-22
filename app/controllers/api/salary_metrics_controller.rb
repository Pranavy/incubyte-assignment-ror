# frozen_string_literal: true

module Api
  class SalaryMetricsController < ApplicationController
    before_action :authenticate_admin!

    def by_job_title
      as_of = SalaryMetrics::ForJobTitle.parse_as_of(params[:as_of])
      payload = SalaryMetrics::ForJobTitle.call(job_title_id: params[:job_title_id], as_of: as_of)
      return head :not_found if payload.nil?

      render json: payload
    end

    def by_country
      if params[:country].blank?
        render json: { error: "country is required" }, status: :unprocessable_content
        return
      end

      as_of = SalaryMetrics::ForJobTitle.parse_as_of(params[:as_of])
      payload = SalaryMetrics::ForCountry.call(country: params[:country], as_of: as_of)
      if payload.nil?
        render json: { error: "country is not a valid country code" }, status: :unprocessable_content
        return
      end

      render json: payload
    end
  end
end
