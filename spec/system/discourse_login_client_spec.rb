# frozen_string_literal: true

describe "discourse login client auth" do
  include OmniauthHelpers

  before do
    OmniAuth.config.test_mode = true
    SiteSetting.discourse_login_client_enabled = true
    SiteSetting.discourse_login_client_id = "asdasd"
    SiteSetting.discourse_login_client_secret = "wada"

    OmniAuth.config.mock_auth[:discourse_login] = OmniAuth::AuthHash.new(
      provider: "discourse_login",
      uid: OmniauthHelpers::UID,
      info:
        OmniAuth::AuthHash::InfoHash.new(
          email: OmniauthHelpers::EMAIL,
          username: OmniauthHelpers::USERNAME,
        ),
    )

    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
  end

  after { reset_omniauth_config(:discourse_login) }

  let(:signup_form) { PageObjects::Pages::Signup.new }

  context "when user does not exist" do
    it "skips the signup form & create the account directly" do
      visit("/")
      signup_form.open.click_social_button("discourse_login")
      expect(page).to have_css(".header-dropdown-toggle.current-user")
    end
  end

  context "when user exists" do
    fab!(:user) do
      Fabricate(:user, email: OmniauthHelpers::EMAIL, username: OmniauthHelpers::USERNAME)
    end

    it "logs in user" do
      visit("/")
      signup_form.open.click_social_button("discourse_login")
      expect(page).to have_css(".header-dropdown-toggle.current-user")
    end
  end
end
