# frozen_string_literal: true

describe "discourse login client auth" do
  include OmniauthHelpers

  before do
    OmniAuth.config.test_mode = true
    SiteSetting.full_page_login = true
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

  let(:login_form) { PageObjects::Pages::Login.new }
  let(:signup_form) { PageObjects::Pages::Signup.new }

  context "when user does not exist" do
    it "fills the signup form" do
      visit("/")

      signup_form.open.click_social_button("discourse_login")
      expect(signup_form).to be_open
      expect(signup_form).to have_no_password_input
      expect(signup_form).to have_valid_username
      expect(signup_form).to have_valid_email
      signup_form.click_create_account
      expect(page).to have_css(".header-dropdown-toggle.current-user")
    end

    context "when skipping the signup form" do
      before { SiteSetting.auth_skip_create_confirm = true }

      it "creates the account directly" do
        visit("/")

        signup_form.open.click_social_button("discourse_login")
        expect(page).to have_css(".header-dropdown-toggle.current-user")
      end
    end
  end

  context "when user exists" do
    fab!(:user) do
      Fabricate(
        :user,
        email: OmniauthHelpers::EMAIL,
        username: OmniauthHelpers::USERNAME,
        password: "supersecurepassword",
      )
    end

    it "logs in user" do
      visit("/")

      signup_form.open.click_social_button("discourse_login")
      expect(page).to have_css(".header-dropdown-toggle.current-user")
    end
  end
end
