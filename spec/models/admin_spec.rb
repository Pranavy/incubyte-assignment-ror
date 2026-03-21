# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin, type: :model do
  def build_admin(attrs = {})
    described_class.new(
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      **attrs
    )
  end

  describe "validations and Devise validatable" do
    it "is valid with email and matching password confirmation" do
      admin = build_admin
      expect(admin).to be_valid
      expect(admin.save).to be true
    end

    it "persists an encrypted password, not the plain password" do
      admin = build_admin
      admin.save!
      expect(admin.encrypted_password).to be_present
      expect(admin.encrypted_password).not_to eq("password123")
    end

    it "is invalid without an email" do
      admin = build_admin(email: nil)
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to be_present
    end

    it "is invalid with a duplicate email (case-insensitive per Devise)" do
      build_admin(email: "dup@example.com").save!
      other = build_admin(email: "DUP@example.com")
      expect(other).not_to be_valid
      expect(other.errors[:email]).to be_present
    end

    it "is invalid without a password on create" do
      admin = build_admin(password: nil, password_confirmation: nil)
      expect(admin).not_to be_valid
      expect(admin.errors[:password]).to be_present
    end

    it "is invalid when password and confirmation do not match" do
      admin = build_admin(password_confirmation: "different123")
      expect(admin).not_to be_valid
      expect(admin.errors[:password_confirmation]).to be_present
    end

    it "is invalid when password is shorter than Devise minimum length" do
      admin = build_admin(password: "short", password_confirmation: "short")
      expect(admin).not_to be_valid
      expect(admin.errors[:password]).to be_present
    end
  end

  describe "#valid_password?" do
    it "returns true for the correct password" do
      admin = build_admin
      admin.save!
      expect(admin.valid_password?("password123")).to be true
    end

    it "returns false for a wrong password" do
      admin = build_admin
      admin.save!
      expect(admin.valid_password?("wrong-password")).to be false
    end
  end
end
