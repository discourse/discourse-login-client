# frozen_string_literal: true

class DiscourseLoginClientStrategy < ::OmniAuth::Strategies::OAuth2
  option :name, "discourse_login"

  option :client_options, auth_scheme: :basic_auth

  def authorize_params
    super.tap { _1[:intent] = "signup" if request.params["signup"] == "true" }
  end

  def callback_url
    Discourse.base_url_no_prefix + callback_path
  end

  uid { access_token.params["info"]["uuid"] }

  info do
    {
      nickname: access_token.params["info"]["username"],
      email: access_token.params["info"]["email"],
      image: access_token.params["info"]["image"],
    }
  end
end
