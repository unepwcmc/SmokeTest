require 'net/http'
require 'json'
require 'openssl'

class SmokeTest
  def initialize
    secrets = Rails.application.secrets
    @urls = secrets.smoke_test[:urls]
    @http_header = secrets.smoke_test[:http_header]
    @api_token = secrets.smoke_test[:api_token] || ""
    @slack_uri = secrets.smoke_test[:slack_uri]
    @slack_token = secrets.smoke_test[:slack_token]
    @slack_room = secrets.smoke_test[:slack_room]
    @slack_username = secrets.smoke_test[:slack_username]
    @slack_emoji = secrets.smoke_test[:slack_emoji]
  end

  def test_endpoints
    message = ""

    unless @urls.nil?
      @urls.each do |url|
        if /api/.match(url)
          curl_result = `curl -i -s -w "%{http_code}" #{url} -H "#{@http_header}:#{@api_token}" -o /dev/null`
        else
          curl_result = `curl -s -w "%{http_code}" #{url} -o /dev/null`
        end

        if curl_result == "200"
          message << "#{url} passed the smoke test\n"
        elsif curl_result == "302"
          message << "#{url} passed the smoke test with a redirection\n"
        else
          message << "#{url} failed the smoke test\n"
        end
       end
    else
      message << "Urls are not properly configured"
    end

    slack_smoke_notification message
  end

  def slack_smoke_notification(message)
    uri = URI.parse("#{@slack_uri}/#{@slack_token}")

    payload = {
      channel: @slack_room,
      username: @slack_username,
      text: message,
      icon_emoji: @slack_emoji
    }

    response = nil

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({ :payload => JSON.generate(payload) })

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    http.start do |h|
      response = h.request(request)
    end
  end

end
