# SmokeTest

A smoke testing gem, which sends alerts using Slack.
Although this gem could potentially be used with other web services.

Add the gem to your Rails project Gemfile and run `bundle install`.

## Update your Rails secrets

```
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  smoke_test:
    urls: ["http://www.example.com", "http://www.example2.com"]
    http_header: "X-Authentication-Token"
    api_token: "XXXXXX"
    slack_uri: "XXXXXX"
    slack_token: "XXXXXX"
    slack_room: "XXXXXX"
    slack_username: "XXXXXX"
    slack_emoji: "XXXXXX"
```

`slack_uri` looks something like this: `https://hooks.slack.com/services/XXXXXXXX/YYYYYYYY`

The `api_token` is necessary when you need to pass an API token to your server and this can passed as an `X-Authentication-Token` for example which is set using the `http_header`. This will be sent to to the server and is used in the case that `"api"` is contained within the url. This can be left blank if not needed.

It is highly recommended to use `ENV` variables to protect your precious credentials. For example: `ENV["SLACK_URI"]` and then define your secrets within the environment.
