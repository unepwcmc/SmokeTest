# SmokeTest

A smoke testing gem.

Add the gem to your Rails project Gemfile and run `bundle install`


## Update your Rails secrets

```
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  smoke_test:
    urls: ["http://www.example.com", "http://www.example2.com"]
    api_token: "XXXXXX"
    slack_uri: "XXXXXX"
    slack_token: "XXXXXX"
    slack_room: "XXXXXX"
    slack_username: "XXXXXX"
    slack_emoji: "XXXXXX"
```

`slack_uri` looks something like this: `https://hooks.slack.com/services/XXXXXXXX/YYYYYYYY`

It is highly recommended to use `ENV` variables to protect your precious credentials. For example: `ENV["SLACK_URI"]` and then define your secrets within the environment.
