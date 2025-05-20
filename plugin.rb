# frozen_string_literal: true

# name: discourse-login-client
# about: Test plugin for Discourse ID authentication. Currently not intended for use in production.
# meta_topic_id: N/A
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 3.3.0

require_relative "lib/discourse_login_client_strategy"
require_relative "lib/discourse_login_client_authenticator"

enabled_site_setting :discourse_login_client_enabled

auth_provider icon: "fab-discourse", authenticator: DiscourseLoginClientAuthenticator.new

after_initialize do
  on_enabled_change do |_, enabled|
    if enabled
      SiteSetting.set(:auth_skip_create_confirm, true)
      SiteSetting.hidden_settings_provider.add_hidden(:auth_skip_create_confirm)
    else
      SiteSetting.set(:auth_skip_create_confirm, false)
      SiteSetting.hidden_settings_provider.remove_hidden(:auth_skip_create_confirm)
    end
  end
end
