---
title: Expense Report application with Rails and Redis
description: Creating a new template with Redis
tags:
    - ruby
    - rails
    - template
---

##Introduction

This section introduces the Expense Report application. It teaches you how to get started with a new Rails application with Redis.

##Prerequisites

+ [Ruby 1.9.2 or above](https://rvm.io/rubies/installing/) and [Rails 3.2](https://github.com/rails/rails) framework has been installed.
+ [Redis](http://redis.io/download) is installed.
+ [rvm](https://rvm.io/) is installed.

Starting a new application in Rails is as simple as executing a single command `rails new <appname>`.

Before starting the new application, let us go through the application overview.

##Subtopics

+ [Expense Report application Overview](#expense-report-application-overview)
+ [Creating a new template with Redis](#creating-new-template-with-redis)
+ [Configuring the application](#configuring-the-application)

##Expense Report application overview

This application helps users in maintaining a record of their expenses. Users can add, edit and delete expense.

Application will have following features:

+ Users will be able to see Expense Report showing with description, amount, expense type and date of expense.

+ Users will be allowed to create a new expense.

##Use case

![Image](/images/screenshots/rails/redis/rails-expense-report-new-template-with-redis/expense-report-use-case.png)


##Creating New Template with Redis

Running an application in Ruby on Rails depends on the versions of Ruby and Rails in which the application has been developed. First decide the versions of both Ruby and Rails.

For now, CloudFoundry supports two versions of Ruby:-

+ ruby1.8.7
+ ruby1.9.2-p180

This tutorial is based on the version 1.9.2-p180. For Rails use 3.2.

Install Ruby through [rvm](https://rvm.io/), a version management for ruby. And choose the Ruby version by following this command.

```bash
$ rvm use 1.9.2-p180
```

`ruby` offeres a good mechanism called `gemset` for handling gems and their dependencies for particular Ruby versions. Create a separate gemset for the Expense Report application.

```bash
$ rvm gemset create rails-expense-report-redis
```

This command will create the expense_report gemset if it isn't existing and in use already. Now, install Rails gem to be able to genarate a new rails application. Use the following command for installing it

```bash
$ gem install rails
```
This will install the latest version of Rails.

This tutorial chooses Redis as the database. Generate the new application without any database by providing the option as `--skip-active-record`

```bash
$ rails new rails-expense-report-redis --skip-active-record
```

This will create a new application without any database configuration and also finish bundle installation.

 Next, go to the application folder.

```bash

$ cd rails-expense-report-redis

```

##Check Point

Start the server by following command.

```bash
$ rails s
```

The server runs on port 3000. Open your browser and go to the url [localhost:3000](http://localhost:3000). The Index page will now be visible

![Image for the index page](/images/screenshots/rails/postgres/rails-new-template-with-postgres/rails-welcome.png)

##Configuring the application

Creating a file with name .rvmrc will tell the rvm to use a particular Ruby version and gemset whenever you enter the application folder through the terminal. Place a file named .rvmrc in the main folder and write the following line in.

```ruby
rvm use 1.9.2-p180@rails-expense-report-redis
```

###Removing the default index.html page

Remove the `public/index.html` page which will be rendered when you start the application in browser.

```bash
$ rm public/index.html
```

###Gemfile

Bundler is a tool that maintains a consistent environment for a developer’s code across all machines. Know more about bundler [here](http://gembundler.com/).
Gemfile is the place where all the gems that are used in the application can be placed. Bundler will install all the gems that are mentioned in the Gemfile along with their dependencies.
In the gem file, replace the `jquery-rails` gem with `cloudfoundry-jquery-rails` and add a gem `ohm`.

`cloudfoundry-jquery-rails` gem is a fork of the original jquery-rails gem including a fix to work with Cloud Foundry.

`cloudfoundry-jquery-rails` gem provides:

+ jQuery 1.7.1
+ jQuery UI 1.8.16
+ Latest jQuery UJS adapter
+ Fix for Cloud Foundry

Ohm is a library that allows to store an object in Redis, a persistent key-value database. It includes an extensible list of validations and has very good performance.
Now the Gemfile will look like below:

```ruby
source 'https://rubygems.org'

gem 'rails', '3.2.9'
gem 'ohm'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

# gem 'therubyracer'

# gem 'jquery-rails'
gem 'cloudfoundry-jquery-rails'
```

Use the gem `therubyracer` if you do not have javascript environment in your system. This will be useful for the assets. To install javascript runtime, install node.js by following [these instructions](http://howtonode.org/how-to-install-nodejs).

Install all the gems by running the following command.

```bash
$ bundle install
```

##Configuring the database

Before doing any redis configuration in the application make sure that you have already installed Redis in your local machine. You can [follow this](http://redis.io/download) to install Redis.
For this application `config/database.yml` file is not required. All the attributes and relationship can be defined inside the model only.
For database storage `ohm` gem will be used. Ohm is a library that allows to store an object in Redis, a persistent key-value database. It includes an extensible list of validations and has very good performance.

##Adding Styles to the application

For Expense Report application UI have been customized. To use these styles, add the css file into your `app/assets/stylesheets` folder. [Get the the CSS files from here](/rails-code/stylesheets-redis.zip)

After adding the css files, [get the images from here](/rails-code/ui-images-redis.zip) and place them in your `app/assets/images` folder.

Before moving to view files, lets understand what are `erb` extensions. ERB provides powerful templation system for Ruby. Using ERB. actual Ruby code can be added to any plain text document for the purposes of generating document information details.

`app/views` directory is the part from which HTML is displayed in web browser. Rails have a concept of `layouts`, which are containers for view. Checkout the `app/views/layouts` directory, it contains an `application.html.erb` file which is created at time of rails application creation.
`app/views/layouts/application.html.erb` is an application specific layout used for all the controllers. HTML `<head>` tag , `<body>` tag is present in this file.

In `app/views/layouts/application.html.erb` remove all the content and add the following lines:

```rhtml
<!DOCTYPE HTML>
<html>
<head>
  <title>Expense Report</title>
  <%= stylesheet_link_tag "application", :media => "all" %>
  <%= javascript_include_tag "application" %>
  <%= csrf_meta_tags %>
</head>
<body>
<div id="contentWrapper">
  <div class="blue-b">
    <%= render :partial => "layouts/header_nav" %>
  </div>
  <div class="mc-a">
    <%= yield %>
  </div>
</div>
</body>
</html>

```

Above code have used `yield` keyword.

```rhtml
<%= yield %>
```

`yield` function is to identify the section where the content from the view should be inserted. Views corresponding to different actions will be rendered into the unnamed `yield`.

`render` is a function that does the job of rendering applications content for use by browser. In above code we have used `render` function to render a partial `layout/header_nav`.
Partial templates – usually just called `partials` – are another device for breaking the rendering process into more manageable chunks. With a partial, code for rendering can be moved to a particular piece of a response to its own file.


Inside `application.html.erb` file a partial `layout/header_nav` is rendered, hence create a `_header_nav.html.erb` file inside `app/views/layouts`.
In `_header_nav.html.erb` file add the following lines:

```rhtml
<div class="inside-nav">
  <div class="logo">
    <img src="<%= asset_path 'logo.png' %>">
  </div>
</div>

```


##Schema Design
Redis does not uses ActiveRecord for the query interface. Ohm is used as ORM for redis in the rails application. Ohm is an Object-hash mapping library for Redis.There are not going to be any tables or columns or even application specific database. Redis will only store the key-value pair.
By default all the data is stored in `/var/lib/redis/6379/dump.rdb` file.

The application will deal with one Expense model.

```ruby
class Expense < Ohm::Model
  attribute :description
  attribute :amount
  attribute :status
  attribute :date
  attribute :expense_type
end
```

Here the attributes are like columns in the table.
Learn more about Ohm [here](http://ohm.keyvalue.org/)

<a class="button-plain" style="padding: 3px 15px;" href="/ruby/rails-tutorial/rails-getting-started.html">Prev</a>  <a class="button-plain" style="padding: 3px 15px; float: right;" href="/ruby/rails-tutorial/redis/rails-redis-expense-model.html">Next</a>
