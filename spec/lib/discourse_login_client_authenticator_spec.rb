# frozen_string_literal: true

require "rails_helper"

describe DiscourseLoginClientAuthenticator do
  let(:authenticator) { described_class.new }
  let(:user) { Fabricate(:user) }

  context "with default settings" do
    before do
      SiteSetting.discourse_login_client_enabled = true
      SiteSetting.discourse_login_client_id = "client_id"
      SiteSetting.discourse_login_client_secret = "client_secret"
    end

    it "has the right name" do
      expect(authenticator.name).to eq("discourse_login")
    end

    it "can connect to existing user" do
      expect(authenticator.can_connect_existing_user?).to eq(true)
    end

    it "can be revoked" do
      expect(authenticator.can_revoke?).to eq(true)
    end

    it "verifies email by default" do
      expect(authenticator.primary_email_verified?({})).to eq(true)
    end

    it "does not always update user email" do
      expect(authenticator.always_update_user_email?).to eq(false)
    end

    describe "#enabled?" do
      it "is enabled with proper settings" do
        expect(authenticator.enabled?).to eq(true)
      end

      it "is disabled without client id" do
        SiteSetting.discourse_login_client_id = ""
        expect(authenticator.enabled?).to eq(false)
      end

      it "is disabled without client secret" do
        SiteSetting.discourse_login_client_secret = ""
        expect(authenticator.enabled?).to eq(false)
      end

      it "is disabled when `discourse_login_client_enabled` is false" do
        SiteSetting.discourse_login_client_enabled = false
        expect(authenticator.enabled?).to eq(false)
      end
    end

    describe "#base_url" do
      it "returns default URL when setting is blank" do
        SiteSetting.discourse_login_client_url = ""
        expect(authenticator.base_url).to eq("https://logindemo.discourse.group")
      end

      it "returns configured URL when setting is present" do
        SiteSetting.discourse_login_client_url = "https://custom.example.com"
        expect(authenticator.base_url).to eq("https://custom.example.com")
      end
    end
  end

  describe "DiscourseLoginClientStrategy" do
    let(:strategy) { DiscourseLoginClientAuthenticator::DiscourseLoginClientStrategy.new({}) }

    it "uses 'discourse_login' name" do
      expect(strategy.options.name).to eq("discourse_login")
    end

    it "defines client_options" do
      client_options = strategy.options.client_options
      expect(client_options.authorize_url).to eq("/oauth/authorize")
      expect(client_options.token_url).to eq("/oauth/token")
      expect(client_options.auth_scheme).to eq(:basic_auth)
    end

    it "defines authorize_options" do
      expect(strategy.options.authorize_options).to include(:scope)
    end

    it "extracts uid from access_token" do
      access_token =
        instance_double("OAuth2::AccessToken", params: { "info" => { "uuid" => "12345" } })
      allow(strategy).to receive(:access_token).and_return(access_token)
      expect(strategy.uid).to eq("12345")
    end

    it "extracts user info from access_token" do
      access_token =
        instance_double(
          "OAuth2::AccessToken",
          params: {
            "info" => {
              "username" => "test_user",
              "email" => "test@example.com",
              "image" => "http://example.com/avatar.png",
            },
          },
        )
      allow(strategy).to receive(:access_token).and_return(access_token)

      user_info = strategy.info

      expect(user_info[:username]).to eq("test_user")
      expect(user_info[:name]).to eq("test_user")
      expect(user_info[:email]).to eq("test@example.com")
      expect(user_info[:image]).to eq("http://example.com/avatar.png")
    end

    it "defines callback_url" do
      expect(strategy.callback_url).to eq("http://test.localhost/auth/discourse_login/callback")
    end
  end
end
