# frozen_string_literal: true

# name: discourse-login-client
# about: Test plugin
# meta_topic_id: N/A
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 3.3.0

require_relative "lib/discourse_login_client_authenticator"

enabled_site_setting :discourse_login_client_enabled

auth_provider title_setting: "discourse_login_client_button_title",
              icon: "fab-discourse",
              authenticator: DiscourseLoginClientAuthenticator.new
