# frozen_string_literal: true

module Api
  class DashboardController < ApplicationController
    before_action :authenticate_admin!

    def charts
      as_of = SalaryMetrics::ForJobTitle.parse_as_of(params[:as_of])
      top_n = params[:job_title_top_n].presence&.to_i || 10
      countries = parse_countries_param(params[:countries])
      render json: Dashboard::ChartData.call(
        as_of: as_of,
        country_codes: countries,
        job_title_top_n: top_n
      )
    end

    private

    def parse_countries_param(raw)
      list =
        case raw
        when Array then raw
        when String then raw.split(/[\s,]+/).map(&:strip)
        else []
        end
      list.map(&:presence).compact.presence
    end
  end
end
