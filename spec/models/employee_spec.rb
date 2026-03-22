# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  let(:job_title) { JobTitle.create!(title: "Engineer") }

  let(:valid_attributes) do
    {
      first_name: "Ada",
      last_name: "Lovelace",
      job_title: job_title,
      country: "IN",
      salary: BigDecimal("120000.50")
    }
  end

  describe "associations" do
    it "belongs to a job title" do
      employee = described_class.create!(valid_attributes)
      expect(employee.job_title).to eq(job_title)
    end

    it "can be destroyed" do
      employee = described_class.create!(valid_attributes)
      expect { employee.destroy! }.to change(described_class, :count).by(-1)
    end
  end

  describe "validations" do
    it "is valid with all required attributes" do
      employee = described_class.new(valid_attributes)
      expect(employee).to be_valid
      expect(employee.save).to be true
    end

    it "requires first_name" do
      employee = described_class.new(valid_attributes.merge(first_name: nil))
      expect(employee).not_to be_valid
      expect(employee.errors[:first_name]).to include("can't be blank")
    end

    it "requires last_name" do
      employee = described_class.new(valid_attributes.merge(last_name: ""))
      expect(employee).not_to be_valid
      expect(employee.errors[:last_name]).to include("can't be blank")
    end

    it "requires a job title" do
      employee = described_class.new(valid_attributes.merge(job_title: nil))
      expect(employee).not_to be_valid
      expect(employee.errors[:job_title]).to be_present
    end

    it "requires country to be an allowed code" do
      employee = described_class.new(valid_attributes.merge(country: "ZZ"))
      expect(employee).not_to be_valid
      expect(employee.errors[:country]).to be_present
    end

    it "normalizes country to uppercase" do
      employee = described_class.create!(valid_attributes.merge(country: "us"))
      expect(employee.country).to eq("US")
    end

    it "requires salary" do
      employee = described_class.new(valid_attributes.merge(salary: nil))
      expect(employee).not_to be_valid
      expect(employee.errors[:salary]).to be_present
    end

    it "requires salary to be greater than or equal to zero" do
      employee = described_class.new(valid_attributes.merge(salary: -1))
      expect(employee).not_to be_valid
      expect(employee.errors[:salary]).to be_present
    end

    it "allows zero salary" do
      employee = described_class.new(valid_attributes.merge(salary: 0))
      expect(employee).to be_valid
    end
  end

  describe ".build_criteria" do
    it "chains filter_by_country from fltrs" do
      other = JobTitle.create!(title: "Other")
      us = described_class.create!(valid_attributes.merge(country: "US", job_title: other))
      described_class.create!(valid_attributes.merge(country: "IN"))

      result = described_class.build_criteria({ fltrs: { country: "US" } })

      expect(result.to_a).to contain_exactly(us)
    end

    it "applies filter_by_search when search is present" do
      a = described_class.create!(valid_attributes.merge(first_name: "Zara", last_name: "Unique"))
      described_class.create!(valid_attributes.merge(first_name: "Other", last_name: "Person"))

      result = described_class.build_criteria({ search: "Zara" })

      expect(result.to_a).to contain_exactly(a)
    end

    it "ignores unknown fltrs keys when no matching scope exists" do
      described_class.create!(valid_attributes)

      expect do
        described_class.build_criteria({ fltrs: { unknown_field: "x" } })
      end.not_to raise_error
    end

    it "orders newest first when no sort is specified" do
      older = described_class.create!(valid_attributes.merge(first_name: "Older"))
      newer = described_class.create!(valid_attributes.merge(first_name: "Newer"))
      older.update_columns(created_at: 2.days.ago, updated_at: 2.days.ago)
      newer.update_columns(created_at: 1.day.ago, updated_at: 1.day.ago)

      result = described_class.build_criteria({})

      expect(result.first).to eq(newer)
      expect(result.second).to eq(older)
    end
  end
end
