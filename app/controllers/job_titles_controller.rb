# frozen_string_literal: true

class JobTitlesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_job_title, only: %i[show edit update]

  def index
    @job_titles = JobTitle.order(:title)
  end

  def show; end

  def new
    @job_title = JobTitle.new
  end

  def create
    @job_title = JobTitle.new(job_title_params)
    if @job_title.save
      redirect_to job_title_path(@job_title), notice: "Job title was successfully created."
    else
      flash.now[:alert] = "Job title could not be created. Please fix the errors below."
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @job_title.update(job_title_params)
      redirect_to job_title_path(@job_title), notice: "Job title was successfully updated."
    else
      flash.now[:alert] = "Job title could not be updated. Please fix the errors below."
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_job_title
    @job_title = JobTitle.find(params[:id])
  end

  def job_title_params
    params.require(:job_title).permit(:title)
  end
end
