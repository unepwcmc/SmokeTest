require 'net/http'
require 'json'
require 'openssl'

class SmokeTest
  def initialize
    secrets         = Rails.application.secrets
    @urls           = secrets.smoke_test[:urls] || []
    @http_header    = secrets.smoke_test[:http_header]
    @api_token      = secrets.smoke_test[:api_token] || ""
    @slack_uri      = secrets.smoke_test[:slack_uri]
    @slack_token    = secrets.smoke_test[:slack_token]
    @slack_room     = secrets.smoke_test[:slack_room]
    @slack_username = secrets.smoke_test[:slack_username]
    @slack_emoji    = secrets.smoke_test[:slack_emoji]
  end

  def test_endpoints
    messages = []

    if @urls.blank?
      messages << "Please set the urls as an array in the Rails secrets or see the documentation."
    end

    @urls.each do |url|
      messages << test_url(url)
    end

    slack_smoke_notification(messages)
  end

  def test_url(url)
    response = curl_result(url)
    parse_response(response, url)
  end

  def curl_result(url)
    if /api/.match(url)
      `curl -i -s -w "%{http_code}" #{url} -H "#{@http_header}:#{@api_token}" -o /dev/null`
    else
      `curl -s -w "%{http_code}" #{url} -o /dev/null`
    end
  end

  def parse_response(response, url)
    case response
    when "200" then "#{url} passed the smoke test"
    when "302" then "#{url} passed the smoke test with a redirection"
    else "#{url} failed the smoke test"
    end
  end

  def format_messages(messages)
    "Smoke Test results\n" + messages.join("\n")
  end

  def slack_smoke_notification(messages)
    uri = URI.parse("#{@slack_uri}/#{@slack_token}")

    payload = {
      channel:    @slack_room,
      username:   @slack_username,
      text:       format_messages(messages),
      icon_emoji: @slack_emoji
    }

    Net::HTTP.post_form(uri, {payload: JSON.generate(payload)})
  end
end
