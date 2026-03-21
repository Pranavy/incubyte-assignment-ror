# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bootstrap layout", type: :request do
  it "serves the home page with Bootstrap assets from the CDN" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("cdn.jsdelivr.net/npm/bootstrap")
  end
end
