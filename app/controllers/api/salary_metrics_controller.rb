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
  end
end
