# frozen_string_literal: true

class DiscourseLoginClientAuthenticator < Auth::ManagedAuthenticator
  def enabled?
    SiteSetting.discourse_login_client_enabled && SiteSetting.discourse_login_client_id.present? &&
      SiteSetting.discourse_login_client_secret.present?
  end

  def name
    "discourse_login"
  end

  def display_name
    "Discourse ID"
  end

  def site
    SiteSetting.discourse_login_client_url.presence || "https://logindemo.discourse.group"
  end

  def register_middleware(omniauth)
    omniauth.provider DiscourseLoginClientStrategy,
                      scope: "read",
                      setup: ->(env) do
                        env["omniauth.strategy"].options.merge!(
                          client_id: SiteSetting.discourse_login_client_id,
                          client_secret: SiteSetting.discourse_login_client_secret,
                          client_options: {
                            site:,
                          },
                        )
                      end
  end

  def primary_email_verified?(auth_token)
    true # email will be verified at source
  end
end
