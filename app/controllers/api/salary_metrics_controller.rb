# frozen_string_literal: true

module Api
  class SalaryMetricsController < ApplicationController
    before_action :authenticate_admin!

    def by_job_title
      title = JobTitle.find_by(id: params[:job_title_id])
      return head :not_found unless title

      employees = Employee.where(job_title_id: title.id)
      as_of = parse_as_of_date

      if employees.empty?
        render json: {
          job_title_id: title.id,
          job_title: title.title,
          avg_gross_salary: nil,
          avg_net_salary: nil
        }
        return
      end

      avg_gross = employees.average(:salary)
      total_net = employees.inject(BigDecimal("0")) do |acc, employee|
        rate = TdsRule.effective_tds_rate_for_country(employee.country, as_of: as_of)
        acc + (employee.salary * (BigDecimal("1") - rate))
      end
      avg_net = total_net / employees.count

      render json: {
        job_title_id: title.id,
        job_title: title.title,
        avg_gross_salary: avg_gross&.to_f,
        avg_net_salary: avg_net.to_f
      }
    end

    private

    def parse_as_of_date
      return Date.current if params[:as_of].blank?

      Date.parse(params[:as_of].to_s)
    rescue ArgumentError, TypeError
      Date.current
    end
  end
end
