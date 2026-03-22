# frozen_string_literal: true

module SalaryMetrics
  class ForCountry
    def self.call(country:, as_of: Date.current)
      code = normalize_country(country)
      return nil unless code

      employees = Employee.where(country: code)

      if employees.empty?
        return {
          country: code,
          min_gross_salary: nil,
          max_gross_salary: nil,
          avg_gross_salary: nil,
          min_net_salary: nil,
          max_net_salary: nil,
          avg_net_salary: nil
        }
      end

      grosses = employees.pluck(:salary)
      min_gross = grosses.min
      max_gross = grosses.max
      avg_gross = employees.average(:salary)

      nets = employees.map do |employee|
        rate = TdsRule.effective_tds_rate_for_country(employee.country, as_of: as_of)
        employee.salary * (BigDecimal("1") - rate)
      end

      {
        country: code,
        min_gross_salary: min_gross.to_f,
        max_gross_salary: max_gross.to_f,
        avg_gross_salary: avg_gross&.to_f,
        min_net_salary: nets.min.to_f,
        max_net_salary: nets.max.to_f,
        avg_net_salary: (nets.sum(0.to_d) / nets.size).to_f
      }
    end

    def self.normalize_country(param)
      return nil if param.blank?

      code = param.to_s.strip.upcase
      return nil unless Countries.valid_key?(code)

      code
    end
  end
end
