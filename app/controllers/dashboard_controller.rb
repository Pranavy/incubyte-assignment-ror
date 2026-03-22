# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_admin!

  def show
    @as_of = SalaryMetrics::ForJobTitle.parse_as_of(params[:as_of])
    @job_title_top_n = params[:job_title_top_n].presence&.to_i || 10
    @selected_countries = Array(params[:countries]).map(&:presence).compact
    @chart_data = Dashboard::ChartData.call(
      as_of: @as_of,
      country_codes: @selected_countries.presence,
      job_title_top_n: @job_title_top_n
    )
  end
end
