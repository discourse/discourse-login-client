# frozen_string_literal: true

require "rails_helper"

describe "SiteSetting" do
  it "overrides auth_skip_create_confirm only when the plugin is enabled" do
    expect(SiteSetting.auth_skip_create_confirm).to eq(false)

    SiteSetting.discourse_login_client_enabled = true

    expect(SiteSetting.auth_skip_create_confirm).to eq(true)
    expect(SiteSetting.hidden_settings).to include(:auth_skip_create_confirm)

    SiteSetting.discourse_login_client_enabled = false

    expect(SiteSetting.auth_skip_create_confirm).to eq(false)
    expect(SiteSetting.hidden_settings).not_to include(:auth_skip_create_confirm)
  end
end
