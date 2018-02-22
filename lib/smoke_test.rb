require 'net/http'
require 'json'
require 'openssl'

class SmokeTest
  def initialize
    secrets         = Rails.application.secrets
    @urls           = secrets.smoke_test[:urls]
    @http_header    = secrets.smoke_test[:http_header]
    @api_token      = secrets.smoke_test[:api_token] || ""
    @slack_uri      = secrets.smoke_test[:slack_uri]
    @slack_token    = secrets.smoke_test[:slack_token]
    @slack_room     = secrets.smoke_test[:slack_room]
    @slack_username = secrets.smoke_test[:slack_username]
    @slack_emoji    = secrets.smoke_test[:slack_emoji]
  end

  def test_endpoints
    message = "SmokeTest results: "
    if @urls.nil?
      message << "Urls are not properly configured"
      slack_smoke_notification message
      return
    end

    @urls.each do |url|
      message << test_url(url)
    end

    slack_smoke_notification message
  end

  def test_url(url)
    if /api/.match(url)
      curl_result = `curl -i -s -w "%{http_code}" #{url} -H "#{@http_header}:#{@api_token}" -o /dev/null`
    else
      curl_result = `curl -s -w "%{http_code}" #{url} -o /dev/null`
    end
    generate_result(curl_result, url)
  end

  def generate_result(curl_result, url)
    case curl_result
    when "200"
      generate_message(url, "passed the smoke test")
    when "302"
      generate_message(url, "passed the smoke test with a redirection")
    else
      generate_message(url, "failed the smoke test")
    end
  end

  def generate_message(url, message)
    "#{url} #{message}\n"
  end

  def slack_smoke_notification(message)
    uri = URI.parse("#{@slack_uri}/#{@slack_token}")

    payload = {
      channel:    @slack_room,
      username:   @slack_username,
      text:       message,
      icon_emoji: @slack_emoji
    }

    Net::HTTP.post_form(uri, {:payload => JSON.generate(payload)})
  end
end
