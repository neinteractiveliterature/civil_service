# CivilService

[![Build Status](https://travis-ci.org/actblue/civil_service.svg?branch=master)](https://travis-ci.org/actblue/civil_service)

CivilService is a tiny framework for [service objects in Rails apps](https://hackernoon.com/service-objects-in-ruby-on-rails-and-you-79ca8a1c946e). With CivilService, you can use ActiveModel validations to do pre-flight checks before the service runs, and create your own result object classes to capture the results of complex operations.

CivilService was extracted from [Intercode](https://github.com/neinteractiveliterature/intercode), a web app for convention organizers and participants.  It was maintained by ActBlue from 2019-2025, and is now back under the maintenance of New England Interactive Literature.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'civil_service'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install civil_service

## What CivilService does

CivilService::Service is really a pretty tiny class.  It does, however, have some opinions that create a potentially-useful abstraction for app developers:

* When called, services always return a result object that responds to (at least) `#success?`, `#failure?`, `#errors`, and `#exception`.  This lets your code paths that call services be consistent and simple.  (If you want to return more information as a result of running the service, it's easy to define a custom result class for your service.)
  * What's the difference between `#errors` and `#exception`?  `#errors` is an instance of `ActiveModel::Errors`, whereas `#exception` is an instance of an exception class (it's only present if an exception was raised inside the service call).  If an exception is raised, the service result will respond true to `#failure?`, false to `#success?`, and the exception's message will be added to `#errors`, so most of the time you can ignore `#exception` - but it's there in case you need to dig into the details.
* Services include `ActiveModel::Validations` so they can easily do pre-flight checks.  That means you can call `my_service.valid?` and `my_service.errors` just like you can for a model, and it also means that the service will fail if it's not valid.
* In addition to `#call`, which always returns a result object, services have a `#call!` method, which will raise a `CivilService::ServiceFailure` exception if the service fails, or pass through an exception if one is raised inside the service call.  This might be easier in some workflows; for example, it will cause a rollback if used inside an ActiveRecord transaction block.
* Finally, there's a third variant: `#call_and_raise`, which will re-raise any exceptions that occurred during the service execution, but will return a regular result object on failure.

## Basic example

Here's a simple service that changes a user's password in a hypothetical Rails app, and sends a
notification email about it:

```ruby
class PasswordChangeService < CivilService::Service
  validate :ensure_valid_password

  attr_reader :user, :new_password

  def initialize(user:, new_password:)
    @user = user
    @new_password = new_password
  end

  private

  def inner_call
    user.update!(password: new_password)
    UserMailer.password_changed(user).deliver_later
    success
  end

  def ensure_valid_password
    return if new_password.length >= 8
    errors.add(:base, "Passwords must be at least 8 characters long")
  end
end
```

You might call this from a controller action like this:

```ruby
class UsersController < ApplicationController
  def change_password
    service = PasswordChangeService.new(user: current_user, new_password: params[:password])
    result = service.call

    if result.success?
      redirect_to root_url, notice: "Your password has been changed."
    else
      flash[:alert] = result.errors.full_messages.join(', ')
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/actblue/civil_service.
