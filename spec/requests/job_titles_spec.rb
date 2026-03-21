# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Job titles (admin)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  describe "authentication" do
    it "redirects to sign in when accessing index while signed out" do
      get job_titles_path

      expect(response).to redirect_to(new_admin_session_path)
    end

    it "redirects to sign in when accessing new while signed out" do
      get new_job_title_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "when signed in as admin" do
    before { sign_in admin, scope: :admin }

    describe "GET /job_titles" do
      it "returns 200 and lists job titles" do
        JobTitle.create!(title: "Engineer")

        get job_titles_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Engineer")
      end
    end

    describe "GET /job_titles/:id" do
      it "returns 200" do
        job_title = JobTitle.create!(title: "Designer")

        get job_title_path(job_title)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Designer")
      end
    end

    describe "GET /job_titles/new" do
      it "returns 200" do
        get new_job_title_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("New job title")
      end
    end

    describe "POST /job_titles" do
      it "creates a job title, redirects with 302, and sets a flash notice" do
        expect do
          post job_titles_path, params: { job_title: { title: "New Role" } }
        end.to change(JobTitle, :count).by(1)

        expect(response).to redirect_to(job_title_path(JobTitle.find_by!(title: "New Role")))
        expect(flash[:notice]).to include("successfully created")
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "returns 422 and does not create when title is invalid" do
        expect do
          post job_titles_path, params: { job_title: { title: "" } }
        end.not_to change(JobTitle, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when title is not unique" do
        JobTitle.create!(title: "Taken")

        expect do
          post job_titles_path, params: { job_title: { title: "Taken" } }
        end.not_to change(JobTitle, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "GET /job_titles/:id/edit" do
      it "returns 200" do
        job_title = JobTitle.create!(title: "Analyst")

        get edit_job_title_path(job_title)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Edit job title")
      end
    end

    describe "PATCH /job_titles/:id" do
      it "updates the job title, redirects with 302, and sets a flash notice" do
        job_title = JobTitle.create!(title: "Old Name")

        patch job_title_path(job_title), params: { job_title: { title: "New Name" } }

        expect(response).to redirect_to(job_title_path(job_title))
        expect(flash[:notice]).to include("successfully updated")
        expect(job_title.reload.title).to eq("New Name")
        follow_redirect!
      end

      it "returns 422 when update is invalid" do
        job_title = JobTitle.create!(title: "Valid")

        patch job_title_path(job_title), params: { job_title: { title: "" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(job_title.reload.title).to eq("Valid")
      end

      it "returns 422 when new title conflicts with another record" do
        JobTitle.create!(title: "Other")
        job_title = JobTitle.create!(title: "Mine")

        patch job_title_path(job_title), params: { job_title: { title: "Other" } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
