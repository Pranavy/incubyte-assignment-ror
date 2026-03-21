module ApplicationHelper
  def admin_auth_card(title:, &block)
    body = capture(&block)
    render partial: "admins/shared/auth_card", locals: { title: title, body: body }
  end
end
