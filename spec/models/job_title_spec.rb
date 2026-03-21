# frozen_string_literal: true

require "rails_helper"

RSpec.describe JobTitle, type: :model do
  describe "validations" do
    it "requires a title" do
      job_title = described_class.new(title: nil)
      expect(job_title).not_to be_valid
      expect(job_title.errors[:title]).to include("can't be blank")
    end

    it "requires title to be unique" do
      described_class.create!(title: "Software Engineer")

      duplicate = described_class.new(title: "Software Engineer")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:title]).to include("has already been taken")
    end

    it "is valid with a unique title" do
      job_title = described_class.new(title: "Product Manager")
      expect(job_title).to be_valid
    end
  end
end
