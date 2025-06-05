# frozen_string_literal: true

# name: discourse-login-client
# about: Test plugin for Discourse ID authentication. Currently not intended for use in production.
# version: 0.0.1
# authors: Discourse
# required_version: 3.3.0

require_relative "lib/discourse_login_client_strategy"
require_relative "lib/discourse_login_client_authenticator"

enabled_site_setting :discourse_login_client_enabled

auth_provider icon: "fab-discourse", authenticator: DiscourseLoginClientAuthenticator.new

after_initialize do
  require_relative "app/controllers/discourse_login_client/auth_controller"

  Discourse::Application.routes.append do
    post "/auth/discourse_login/revoke" => "discourse_login_client/auth#revoke"
  end
end
