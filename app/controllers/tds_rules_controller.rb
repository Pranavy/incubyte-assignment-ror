# frozen_string_literal: true

class TdsRulesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_tds_rule, only: %i[show edit update]

  def index
    @tds_rules = TdsRule.order(:country, effective_from: :desc).paginate(page: params[:page])
  end

  def show; end

  def new
    @tds_rule = TdsRule.new(tds_rate: 0)
  end

  def create
    @tds_rule = TdsRule.new(tds_rule_params)
    if @tds_rule.save
      redirect_to tds_rule_path(@tds_rule), notice: "TDS rule was successfully created."
    else
      flash.now[:alert] = "TDS rule could not be created. Please fix the errors below."
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @tds_rule.update(tds_rule_params)
      redirect_to tds_rule_path(@tds_rule), notice: "TDS rule was successfully updated."
    else
      flash.now[:alert] = "TDS rule could not be updated. Please fix the errors below."
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_tds_rule
    @tds_rule = TdsRule.find(params[:id])
  end

  def tds_rule_params
    permitted = params.require(:tds_rule).permit(:country, :tds_rate, :effective_from, :effective_to)
    permitted[:effective_to] = nil if permitted[:effective_to].blank?
    permitted
  end
end
