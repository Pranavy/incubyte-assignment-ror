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
end
