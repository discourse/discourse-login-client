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
    it "skips the signup form and creates the account directly" do
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

  context "when discourse_login is the only external login method" do
    before do
      SiteSetting.enable_discord_logins = false
      SiteSetting.enable_facebook_logins = false
      SiteSetting.enable_github_logins = false
      SiteSetting.enable_google_oauth2_logins = false
      SiteSetting.enable_linkedin_oidc_logins = false
      SiteSetting.enable_local_logins = false
      SiteSetting.enable_twitter_logins = false
    end

    it "hides regular auth buttons and shows continue with discourse id button" do
      visit("/")

      expect(page).not_to have_css(".auth-buttons .sign-up-button")
      expect(page).not_to have_css(".auth-buttons .login-button")

      expect(page).to have_css(
        ".continue-with-discourse",
        text: I18n.t("js.discourse_login.continue_with"),
      )
    end

    it "continues with discourse login when button is clicked" do
      visit("/")

      page.find(".continue-with-discourse").click

      expect(page).to have_css(".header-dropdown-toggle.current-user")

      expect(page).not_to have_css(".continue-with-discourse")
    end
  end
end
