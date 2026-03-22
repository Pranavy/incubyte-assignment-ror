# frozen_string_literal: true

class SalaryMetricsController < ApplicationController
  before_action :authenticate_admin!

  def show
    @job_titles = JobTitle.order(:title)
    @as_of = SalaryMetrics::ForJobTitle.parse_as_of(params[:as_of])
    @job_title_id = params[:job_title_id].presence

    @metrics = if @job_title_id.present?
      SalaryMetrics::ForJobTitle.call(job_title_id: @job_title_id, as_of: @as_of)
    end
  end
end
