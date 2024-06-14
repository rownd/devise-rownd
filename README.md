# Devise::Rownd

[![Gem Version](https://badge.fury.io/rb/devise-rownd.svg)](https://badge.fury.io/rb/devise-jwt)

`devise-rownd` is a [devise](https://github.com/heartcombo/devise) extension that auuthenticates users with Rownd's passwordless authentication strategies. It works in-tandem with the Rownd Hub, a javascript snippet embedded in your website. With this Gem installed, Rownd handles all aspects of user authentication and gives you the tools to customize the user experience on your site.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'devise-rownd'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install devise-rownd
```

### Mount the Engine

Add this to your `config/routes.rb` file

```rb
mount Devise::Rownd::Engine, at: '/api/auth/rownd'
```

### Rownd Hub
Follow [these instructions](https://docs.rownd.io/rownd/sdk-reference/web/javascript-browser) to install the Rownd Hub. You'll want to ensure it runs on every page of your application, so be sure to add it as a common in your Rails JS packs. Here's the easiest way to do that:

1. Create a new file in your JS packs director called `rph.js` and paste the JS snippet that you obtained from the instructions listed above.

3. Add the following API callbacks to your Javascript:
```javascript
_rphConfig.push(['setPostAuthenticationApi', {
  method: 'post',
  url: '/api/auth/rownd/authenticate'
}]);

_rphConfig.push(['setPostSignOutApi', {
  method: 'POST',
  url: '/api/auth/rownd/sign_out'
}]);

_rphConfig.push(['setPostUserDataUpdateApi', {
  method: 'POST',
  url: '/api/auth/rownd/update_data'
}]);
```

> NOTE: The path prefix `/api/auth/rownd` must match the `Devise::Rownd::Engine` mount path that you specified in your Rails routes

3. Finally, include the Javascript pack in your application layout.
```html
<body>
  <%= show_rownd_signin_if_required %>
  <%= yield %>
  <%= javascript_pack_tag 'rph', 'data-turbolinks-track': 'reload' %>
</body>
```
There are two key pieces that you musut include in the layout:

`<%= show_rownd_signin_if_required %>`
This renders the Rownd sign in modal to prompt the user for authentication when your app explicitly requires it in a controller

`<%= javascript_pack_tag 'rph', 'data-turbolinks-track': 'reload' %>`
Tells Rails to include the rph Javascript pack. We also tell Turbolinks to include the script on page reloads

## Usage

For this to work, you need to define these key environment variables:

* `ROWND_APP_KEY` - Your Rownd application key
* `ROWND_APP_SECRET` - Your Rownd application secret

You can get all of these values from the [Rownd Platform](https://app.rownd.io)

### Users

This gem provides a new Devise module named `:rownd_authenticatable`. In your `user` model, you can tell Devise to use it like this:

```ruby
class User < ApplicationRecord
  devise :rownd_authenticatable

  ...
end

```

Now, in your `config/routes.rb` file, add the following:

```ruby
Rails.application.routes.draw do
  devise_for :users
  ...

  mount Devise::Rownd::Engine, at: '/api/auth/rownd'
end
```

### Require Authentication

You can require authentication on a controller's actions the same way you uwould for any Devise strategies.

```ruby
class MyController < ApplicationController
  before_action :authenticate_user!

  ...
end
```

Now, whenever a user navigates to a route that requires authentication, if a user is not already signed in, Devise will prompt the user to sign into Rownd.

### Customizing the Page using the `current_user`

In any of your controllers, views, or helpers, you have access to the currently authenticated user via the `current_user` variable. You can use it to customize your page content like this:

```html
<h1>Hello, <%= current_user.first_name %>!</h1>
```

The `current_user` object has all of the fields specified in your Rownd application's schema. If the user doesn't have a value for a particular field, it will be `nil`

### Extending the `current_user` model

You can extend the `current_user` object by modifying the `Devise::Rownd::User` class. This can be very helpful if you want to have additionanl functions that aggregate data accross multiple fields, or perform some logic and return the result.

For instance, you might want a function called `admin?` that will return if the current user is has an `admin` role. To extend the `current_user` object, add a new initializer in `config/initializers` called `devise_rownd.rb`. In there you can modify the `Devise::Rownd::User` like this:

```ruby
Devise::Rownd::User.class_eval do
  def admin?
    roles&.include?('admin')
  end

  def display_name
    fullname = "#{first_name} #{last_name}"
    fullname.present? ? fullname.strip.upcase : email&.upcase
  end

  ...
end
```

Now, you can call things like `current_user.admin?` and `current_user.display_name`



### Further Customization

All of the other Rownd HTML attributes work as well. You can see a full list of them [here](). This means you have the ability to customize the page with pure HTML, rather than Ruby code, if you prefer

## Contributing
Please feel free to open up a pull request with any improvements, features, or bug fixes. This is a community effort!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
