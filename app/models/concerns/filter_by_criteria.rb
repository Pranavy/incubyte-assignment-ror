# frozen_string_literal: true

# Extend on ActiveRecord models that define `scope :filter_by_*` methods.
# Pass ActionController::Parameters or a Hash with optional :search, :fltrs (use fltrs for all filter fields + sort).
#
# Example: Model.build_criteria(params)
module FilterByCriteria
  def build_criteria(raw_params = {})
    params = normalize_build_params(raw_params)
    filters = all

    fltrs = params[:fltrs]
    fltrs = fltrs.to_unsafe_h if fltrs.is_a?(ActionController::Parameters)
    fltrs = {} unless fltrs.is_a?(Hash)
    fltrs = fltrs.with_indifferent_access

    fltrs.each do |key, value|
      next if key.to_s == "sort"
      next unless value.present? || value.to_s == "nil"

      resolved = value.to_s == "nil" ? nil : value
      next if resolved.blank? && value.to_s != "nil"

      scope_name = "filter_by_#{key}"
      filters = filters.public_send(scope_name, resolved) if respond_to?(scope_name)
    end

    if params[:search].present? && respond_to?(:filter_by_search)
      filters = filters.filter_by_search(params[:search])
    end

    sort_str = fltrs[:sort]
    field_name, sort_order = sort_str.to_s.split(".", 2)
    apply_order_by_criteria(filters, field_name, sort_order)
  end

  private

  def normalize_build_params(raw)
    case raw
    when ActionController::Parameters
      raw.to_unsafe_h.with_indifferent_access
    when Hash
      raw.with_indifferent_access
    when nil
      {}.with_indifferent_access
    else
      {}.with_indifferent_access
    end
  end

  def apply_order_by_criteria(relation, field_name, sort_order)
    if field_name.to_s.blank? && sort_order.to_s.blank?
      if relation.klass.respond_to?(:default_build_criteria_order)
        return relation.klass.default_build_criteria_order(relation)
      end
      return relation.order(created_at: :desc)
    end

    columns = try(:filter_sortable_columns) || %w[created_at]
    field = field_name.to_s.presence
    field = nil unless field && columns.include?(field)
    field ||= "created_at"

    dir = sort_order.to_s.downcase
    dir = "desc" unless %w[asc desc].include?(dir)

    relation.order(field => dir.to_sym)
  end
end
