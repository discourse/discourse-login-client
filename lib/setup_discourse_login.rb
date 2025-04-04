# frozen_string_literal: true

if SiteSetting.discourse_login_client_id.present? ||
     SiteSetting.discourse_login_client_secret.present?
  puts "❌ Discourse Login already configured."
  exit
end

if GlobalSetting.discourse_login_api_key.blank?
  puts "❌ Missing Discourse Login API key."
  exit
end

require "json"
require "net/http"

uri =
  URI.join(
    SiteSetting.discourse_login_client_url.presence || "https://logindemo.discourse.group",
    "/register.json",
  )

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri.path)
request["Accept"] = "application/json"
request["Content-Type"] = "application/json"
request["Discourse-Login-Api-Key"] = GlobalSetting.discourse_login_api_key
request.body = {
  client_name: SiteSetting.title,
  redirect_uri: "#{Discourse.base_url}/auth/discourse_login/callback",
}.to_json

response = http.request(request)
result = JSON.parse(response.body)

if response.code != "200"
  puts "❌ Failed to register Discourse Login client."
  puts "Response code: #{response.code}"
  puts "Error: #{result["error"]}" if result.has_key?("error")
  puts "Errors: #{result["errors"].join(", ")}" if result.has_key?("errors")
  exit
end

if result.has_key?("client_id") && result.has_key?("client_secret")
  SiteSetting.discourse_login_client_id = result["client_id"]
  SiteSetting.discourse_login_client_secret = result["client_secret"]
  SiteSetting.discourse_login_client_enabled = true
else
  puts "❌ Unexpected response format from Discourse Login."
  exit
end

puts "✅ Discourse Login configured successfully."
