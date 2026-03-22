# frozen_string_literal: true

module Dashboard
  # Aggregates for admin dashboard charts. +country_codes+ filters dimensions (default: all
  # Countries::KEYS in catalog order). +job_title_top_n+ limits job-title chart to top N titles by headcount.
  class ChartData
    MAX_JOB_TITLE_SLICES = 50
    PIE_MAX_SLICES = 6

    def self.call(as_of: Date.current, country_codes: nil, job_title_top_n: 10)
      new(as_of: as_of, country_codes: country_codes, job_title_top_n: job_title_top_n).to_h
    end

    def initialize(as_of:, country_codes: nil, job_title_top_n: 10)
      @as_of = as_of
      @country_codes = normalize_country_codes(country_codes)
      @job_title_top_n = job_title_top_n.to_i.clamp(1, MAX_JOB_TITLE_SLICES)
    end

    def to_h
      labels = country_labels_ordered
      slice_count = labels.length
      share_type = slice_count <= PIE_MAX_SLICES ? "pie" : "bar"

      {
        as_of: @as_of.iso8601,
        filters: {
          country_codes: ordered_country_codes,
          job_title_top_n: @job_title_top_n
        },
        headcount_share_chart_type: share_type,
        headcount_by_country: headcount_by_country,
        avg_gross_by_country: avg_gross_by_country,
        headcount_share_by_country: headcount_by_country,
        avg_gross_and_net_by_country: avg_gross_and_net_by_country,
        avg_gross_by_job_title: avg_gross_by_job_title_top_n
      }
    end

    private

    def normalize_country_codes(raw)
      codes =
        case raw
        when Array then raw
        when String then raw.split(/[\s,]+/).map(&:strip)
        else []
        end
      codes = codes.map(&:upcase).select { |c| Countries.valid_key?(c) }.uniq
      codes.presence
    end

    # Catalog order, optionally filtered.
    def ordered_country_codes
      list = normalize_country_codes(@country_codes)
      if list
        Countries::KEYS.select { |c| list.include?(c) }
      else
        Countries::KEYS
      end
    end

    def country_labels_ordered
      ordered_country_codes.map { |code| Countries.label_for(code) || code }
    end

    def headcount_by_country
      counts = Employee.group(:country).count
      labels = []
      values = []
      ordered_country_codes.each do |code|
        labels << (Countries.label_for(code) || code)
        values << counts[code].to_i
      end
      { labels: labels, values: values }
    end

    def avg_gross_by_country
      labels = []
      values = []
      ordered_country_codes.each do |code|
        emps = Employee.where(country: code)
        labels << (Countries.label_for(code) || code)
        values << (emps.empty? ? 0.0 : emps.average(:salary).to_f)
      end
      { labels: labels, values: values }
    end

    def avg_gross_and_net_by_country
      labels = []
      avg_gross = []
      avg_net = []
      ordered_country_codes.each do |code|
        emps = Employee.where(country: code)
        labels << (Countries.label_for(code) || code)
        if emps.empty?
          avg_gross << 0.0
          avg_net << 0.0
        else
          avg_gross << emps.average(:salary).to_f
          total_net = emps.inject(BigDecimal("0")) { |acc, e| acc + net_amount(e) }
          avg_net << (total_net / emps.count).to_f
        end
      end
      { labels: labels, avg_gross: avg_gross, avg_net: avg_net }
    end

    def avg_gross_by_job_title_top_n
      counts = Employee.joins(:job_title).group("job_titles.id", "job_titles.title").count
      sorted = counts.sort_by { |(id, title), cnt| [-cnt, title.to_s] }.first(@job_title_top_n)

      labels = []
      values = []
      sorted.each do |(id, title), _count|
        labels << title
        avg = Employee.where(job_title_id: id).average(:salary)
        values << (avg&.to_f || 0.0)
      end

      { labels: labels, values: values, top_n: @job_title_top_n }
    end

    def net_amount(employee)
      rate = TdsRule.effective_tds_rate_for_country(employee.country, as_of: @as_of)
      employee.salary * (BigDecimal("1") - rate)
    end
  end
end
