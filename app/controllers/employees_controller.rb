# frozen_string_literal: true

class EmployeesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_employee, only: %i[show edit update]
  before_action :load_job_titles, only: %i[new create edit update]

  def index
    @employees = Employee.includes(:job_title).order(:last_name, :first_name).paginate(page: params[:page])
  end

  def show; end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to employee_path(@employee), notice: "Employee was successfully created."
    else
      flash.now[:alert] = "Employee could not be created. Please fix the errors below."
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @employee.update(update_employee_params)
      redirect_to employee_path(@employee), notice: "Employee was successfully updated."
    else
      flash.now[:alert] = "Employee could not be updated. Please fix the errors below."
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def load_job_titles
    @job_titles = JobTitle.order(:title)
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :country, :job_title_id, :salary)
  end

  def update_employee_params
    params.require(:employee).permit(:first_name, :last_name, :country, :job_title_id)
  end
end
