# frozen_string_literal: true

module SalaryMetrics
  class ForJobTitle
    def self.call(job_title_id:, as_of: Date.current)
      title = JobTitle.find_by(id: job_title_id)
      return nil unless title

      employees = Employee.where(job_title_id: title.id)

      if employees.empty?
        return {
          job_title_id: title.id,
          job_title: title.title,
          avg_gross_salary: nil,
          avg_net_salary: nil
        }
      end

      avg_gross = employees.average(:salary)
      total_net = employees.inject(BigDecimal("0")) do |acc, employee|
        rate = TdsRule.effective_tds_rate_for_country(employee.country, as_of: as_of)
        acc + (employee.salary * (BigDecimal("1") - rate))
      end
      avg_net = total_net / employees.count

      {
        job_title_id: title.id,
        job_title: title.title,
        avg_gross_salary: avg_gross&.to_f,
        avg_net_salary: avg_net.to_f
      }
    end

    def self.parse_as_of(raw)
      return Date.current if raw.blank?

      Date.parse(raw.to_s)
    rescue ArgumentError, TypeError
      Date.current
    end
  end
end
