# frozen_string_literal: true

module DiscourseLoginClient
  class AuthController < ApplicationController
    requires_plugin "discourse-login-client"

    skip_before_action :verify_authenticity_token, only: [:revoke]

    def revoke
      signature = params.require(:signature)
      identifier = params.require(:identifier)
      timestamp = params.require(:timestamp)

      RateLimiter.new(nil, "discourse_login_revoke_#{identifier}", 5, 1.minute).performed!

      time_diff = (Time.now.to_i - timestamp.to_i).abs
      if time_diff > 5.minutes.to_i
        if SiteSetting.discourse_login_client_verbose_logging
          Rails.logger.warn(
            "Expired timestamp in discourse_login_client revoke: #{time_diff} seconds old",
          )
        end

        return render_invalid_request
      end

      return render_invalid_request if (client_id = SiteSetting.discourse_login_client_id).blank?

      if (client_secret = SiteSetting.discourse_login_client_secret).blank?
        return render_invalid_request
      end

      hashed_secret = Digest::SHA256.hexdigest(client_secret)

      expected_signature =
        OpenSSL::HMAC.hexdigest("sha256", hashed_secret, "#{client_id}:#{identifier}:#{timestamp}")

      if !ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
        if SiteSetting.discourse_login_client_verbose_logging
          Rails.logger.warn("Invalid signature for user id #{identifier} in discourse_login revoke")
        end

        return render_invalid_request
      end

      unless uaa =
               UserAssociatedAccount.find_by(
                 provider_name: "discourse_login",
                 provider_uid: identifier,
               )
        if SiteSetting.discourse_login_client_verbose_logging
          Rails.logger.warn("User not found with provider_uid: #{identifier}")
        end

        return render_invalid_request
      end

      UserAuthToken.where(user_id: uaa.user_id).destroy_all

      render json: { success: true }
    end

    private

    def render_invalid_request
      render json: { error: "Invalid request" }, status: 400
    end
  end
end
