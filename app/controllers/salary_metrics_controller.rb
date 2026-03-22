# frozen_string_literal: true

class SalaryMetricsController < ApplicationController
  before_action :authenticate_admin!

  def job_title
    @job_titles = JobTitle.order(:title)
    @as_of = SalaryMetrics::ForJobTitle.parse_as_of(params[:as_of])
    @job_title_id = params[:job_title_id].presence

    @metrics_job_title = if @job_title_id.present?
      SalaryMetrics::ForJobTitle.call(job_title_id: @job_title_id, as_of: @as_of)
    end
  end

  def country
    @as_of = SalaryMetrics::ForJobTitle.parse_as_of(params[:as_of])
    @country_param = params[:country].presence

    @metrics_country = if @country_param.present?
      SalaryMetrics::ForCountry.call(country: @country_param, as_of: @as_of)
    end
  end
end
