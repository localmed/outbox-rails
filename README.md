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
# Unlike ActionMailer, deliver takes a single argument that defines the recipients
# for the message types you want to send.
AccountNotifier.welcome.deliver email: 'user@gmail.com', sms: '+15557654321'
```

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
