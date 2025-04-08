# frozen_string_literal: true

class DiscourseLoginClientAuthenticator < Auth::ManagedAuthenticator
  class DiscourseLoginClientStrategy < ::OmniAuth::Strategies::OAuth2
    option :name, "discourse_login"

    option :client_options,
           authorize_url: "/oauth/authorize",
           token_url: "/oauth/token",
           auth_scheme: :basic_auth

    option :authorize_options, [:scope]

    uid { access_token.params["info"]["uuid"] }

    info do
      {
        username: access_token.params["info"]["username"],
        email: access_token.params["info"]["email"],
        image: access_token.params["info"]["image"],
      }
    end

    def callback_url
      Discourse.base_url_no_prefix + script_name + callback_path
    end
  end

  def name
    "discourse_login"
  end

  def can_revoke?
    true
  end

  def can_connect_existing_user?
    true
  end

  def base_url
    SiteSetting.discourse_login_client_url.presence || "https://logindemo.discourse.group"
  end

  def register_middleware(omniauth)
    omniauth.provider DiscourseLoginClientStrategy,
                      setup:
                        lambda { |env|
                          opts = env["omniauth.strategy"].options
                          opts[:client_id] = SiteSetting.discourse_login_client_id
                          opts[:client_secret] = SiteSetting.discourse_login_client_secret
                          opts[:client_options][:site] = base_url
                          opts[:scope] = "read"
                        }
  end

  def primary_email_verified?(auth_token)
    true # email will be verified at source
  end

  def always_update_user_email?
    false # not sure
  end

  def enabled?
    SiteSetting.discourse_login_client_enabled && SiteSetting.discourse_login_client_id.present? &&
      SiteSetting.discourse_login_client_secret.present?
  end
end
