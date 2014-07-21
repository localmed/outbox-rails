Outbox::Rails
=============

[![Gem Version](https://badge.fury.io/rb/outbox-rails.png)](http://badge.fury.io/rb/outbox-rails)

Rails Railtie for sending email, SMS, and push notifications using the [Outbox](https://github.com/localmed/outbox) gem. Please view the [Outbox documentation](https://github.com/localmed/outbox) to understand the philosophy behind this interface and how to use it.

Installation
------------

Add this line to your application's Gemfile:

``` ruby
gem 'outbox-rails'
```

And then execute:

``` bash
$ bundle
```

Or install it yourself as:

``` bash
$ gem install outbox-rails
```

Usage
-----

Outbox::Notifier uses a very similar interface to ActionMailer.

First, define a notifier in `app/notifiers`:

``` ruby
class AccountNotifier < Outbox::Notifier
  default email: { from: 'noreply@myapp.com' },
          sms: { from: '+15551234567' }

  def welcome
    # Compose message types using the Outbox::Message interface
    email do
      subject 'Welcome to our App!'
    end

    sms do
      from '<shortcode_id>'
      # The "text" template will automatically be used for the body of the SMS.
      # But you can explicitly override by calling the #body method.
      body 'Welcome to our App!'
    end

    # Render the body of the message. This is analogous to ActionMailer::Base#mail,
    # but unlike in ActionMailer, #render_message is not required.
    render_message
  end
end
```

Send a message using the `deliver` method:

```ruby
# Unlike ActionMailer, deliver takes an argument that defines the recipients
# for the message types you want to send.
AccountNotifier.welcome.deliver email: 'user@gmail.com', sms: '+15557654321'
```

Configuration
-------------

Configure Outbox using the `config.outbox` accessor during normal Rails
configuration:

``` ruby
# config/application.rb
module Blog
  class Application < Rails::Application
    # Configure defautl email fields
    config.outbox.email_defaults = {
      from: 'from@example.com'
    }

    # Setup default email settings.
    config.outbox.default_email_client_settings = {
      smtp_settings: {
        address: 'smtp.gmail.com',
        port: 587,
        domain: 'example.com',
        user_name: '<username>',
        password: '<password>',
        authentication: 'plain',
        enable_starttls_auto: true
      }
    }
  end
end

# config/environments/test.rb
Blog::Application.configure do
  # Always use test client during tests
  config.outbox.use_test_client = true
end

```

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
