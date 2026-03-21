# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Employees (admin)", type: :request do
  let(:password) { "password123" }
  let!(:admin) do
    Admin.create!(email: "admin@example.com", password: password, password_confirmation: password)
  end

  let!(:engineer_title) { JobTitle.create!(title: "Engineer") }
  let!(:manager_title) { JobTitle.create!(title: "Manager") }

  let(:valid_create_params) do
    {
      employee: {
        first_name: "Jane",
        last_name: "Doe",
        country: "IN",
        job_title_id: engineer_title.id,
        salary: "95000.00"
      }
    }
  end

  describe "authentication" do
    it "redirects to sign in when accessing the employee list while signed out" do
      get employees_path
      expect(response).to redirect_to(new_admin_session_path)
    end

    it "redirects to sign in when accessing new employee while signed out" do
      get new_employee_path
      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "when signed in as admin" do
    before { sign_in admin, scope: :admin }

    describe "GET /employees" do
      it "returns 200 and lists employees" do
        Employee.create!(
          first_name: "Alan",
          last_name: "Turing",
          country: "GB",
          job_title: engineer_title,
          salary: 80_000
        )

        get employees_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Alan")
        expect(response.body).to include("Turing")
        expect(response.body).to include("Engineer")
      end

      it "paginates with page param when there are more records than per page" do
        16.times do |i|
          Employee.create!(
            first_name: "Page",
            last_name: format("%03d", i),
            country: "IN",
            job_title: engineer_title,
            salary: 48_765
          )
        end

        get employees_path(page: 2)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("015")
        expect(response.body).not_to include("000")
        expect(response.body).to include("pagination")
      end
    end

    describe "GET /employees/new" do
      it "returns 200" do
        get new_employee_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("New employee")
      end
    end

    describe "POST /employees" do
      it "creates an employee and redirects with a notice" do
        expect do
          post employees_path, params: valid_create_params
        end.to change(Employee, :count).by(1)

        expect(response).to redirect_to(employee_path(Employee.last))
        expect(flash[:notice]).to include("successfully created")

        employee = Employee.last
        expect(employee.first_name).to eq("Jane")
        expect(employee.country).to eq("IN")
        expect(employee.salary).to eq(BigDecimal("95000.00"))
      end

      it "returns 422 when params are invalid" do
        expect do
          post employees_path, params: {
            employee: valid_create_params[:employee].merge(first_name: "")
          }
        end.not_to change(Employee, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "GET /employees/:id" do
      it "returns 200" do
        employee = Employee.create!(
          first_name: "Grace",
          last_name: "Hopper",
          country: "US",
          job_title: engineer_title,
          salary: 120_000
        )

        get employee_path(employee)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Grace")
        expect(response.body).to include("Hopper")
      end
    end

    describe "GET /employees/:id/edit" do
      it "returns 200" do
        employee = Employee.create!(
          first_name: "Edsger",
          last_name: "Dijkstra",
          country: "DE",
          job_title: engineer_title,
          salary: 100_000
        )

        get edit_employee_path(employee)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Edit employee")
      end
    end

    describe "PATCH /employees/:id" do
      it "updates name, country, and job title" do
        employee = Employee.create!(
          first_name: "Old",
          last_name: "Name",
          country: "IN",
          job_title: engineer_title,
          salary: 50_000
        )

        patch employee_path(employee), params: {
          employee: {
            first_name: "New",
            last_name: "Person",
            country: "US",
            job_title_id: manager_title.id
          }
        }

        expect(response).to redirect_to(employee_path(employee))
        expect(flash[:notice]).to include("successfully updated")

        employee.reload
        expect(employee.first_name).to eq("New")
        expect(employee.last_name).to eq("Person")
        expect(employee.country).to eq("US")
        expect(employee.job_title_id).to eq(manager_title.id)
        expect(employee.salary).to eq(BigDecimal("50000"))
      end

      it "does not change salary even if salary is submitted" do
        employee = Employee.create!(
          first_name: "Pay",
          last_name: "Locked",
          country: "AU",
          job_title: engineer_title,
          salary: 88_888
        )

        patch employee_path(employee), params: {
          employee: {
            first_name: employee.first_name,
            last_name: employee.last_name,
            country: employee.country,
            job_title_id: employee.job_title_id,
            salary: "1.00"
          }
        }

        expect(response).to redirect_to(employee_path(employee))
        expect(employee.reload.salary).to eq(BigDecimal("88888"))
      end

      it "returns 422 when update is invalid" do
        employee = Employee.create!(
          first_name: "Valid",
          last_name: "Employee",
          country: "DE",
          job_title: engineer_title,
          salary: 40_000
        )

        patch employee_path(employee), params: {
          employee: {
            first_name: "",
            last_name: employee.last_name,
            country: employee.country,
            job_title_id: employee.job_title_id
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(employee.reload.first_name).to eq("Valid")
      end
    end
  end
end
