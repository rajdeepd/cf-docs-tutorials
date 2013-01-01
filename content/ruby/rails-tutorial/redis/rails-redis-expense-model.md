---
title: Expense Report application with Rails and Redis
description: Adding Expense model to application
tags:
    - ruby
    - rails
    - expense
    - redis
---

##Introduction

This chapter is a continuation of [chapter 1](/ruby/rails-tutorial/redis/rails-new-template-with-redis.html). This section explains the process of adding expense model to the application in order to persist the expense data.

##Prerequisites

+ Should have completed [chapter 1](/ruby/rails-tutorial/redis/rails-new-template-with-redis.html), that explains creating a basic template.
+ Should know how to use a gems in Rails application.

##Application flow

![Image](/images/rails_redis_tutorial/expense-report-simple-application-flow.png)

##Setup: Exercise2-Starter

If you are starting this chapter from the downloaded source code [Exercise2-Starter.zip](/rails-code/expense-report-redis/Exercise2-starter.zip), please setup the application as described [here](/ruby/rails-tutorial/redis/redis-starters-guide.html) before continuing with this tutorial.

##Adding Expense model to the application

## **Step 1:** Generate Expense model

The Expense model consists of application data and business rules. The controllers are notified if there is a change of state and corresponding views are updated accordingly.

Create a `expense.rb` file in `app/models`

## **Step 2:** Adding Attributes to Expense Model

The generated model is located at `app/models/expense.rb`. Open the file in an editor  and make the following changes.

```ruby
class Expense < Ohm::Model
  attribute :description
  attribute :amount
  attribute :status
  attribute :date
  attribute :expense_type
end

```

Here attributes are like columns in the tables. Changing the attributes of a Redis model can cause inconsistency with previously stored attributes that belong to the model.
In case of Redis there is no need to have any migration. If any attributes are to be added, they must be mentioned in the model itself.


## **Step 3:** Generation of Expense controller

The Expense controller will send commands to its associated view to change the view's presentation of the expense model. It can send commands to the model to update the model's state (e.g., updating a document).

In order to generate the controller , run the following command in the terminal:

```bash
$ rails generate controller  Expenses
```

Running the above command will produce the following the files:

```bash
create  app/controllers/expenses_controller.rb
      invoke  erb
      create    app/views/expenses
      invoke  test_unit
      create    test/functional/expenses_controller_test.rb
      invoke  helper
      create    app/helpers/expenses_helper.rb
      invoke    test_unit
      create      test/unit/helpers/expenses_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/expenses.js.coffee
      invoke    scss
      create      app/assets/stylesheets/expenses.css.scss
```

After generation of controller add the following lines inside `config/routes.rb`:

```ruby
resources :expenses
root :to => "expenses#index"
```

The purpose of Rails router is to recognize URLs and dispatch them to a controller's action. It can also generate paths and URLs, avoiding the need to hardcode strings in views.

`resources :expenses` allows you to quickly declare all of the common routes for expenses controller. Instead of declaring separate routes for your index, show, new, edit, create, update and destroy actions, a resourceful route declares them in a single line of code.

`root :to => "expenses#index"` specify what Rails should route "/" to with the root method. Delete the `public/index.html` file for the root route to take effect.

##Checkpoint

Run the following command to start the server:

```bash
rails s
```
The server runs on port 3000. Open your browser and go to the url [localhost:3000](http://localhost:3000).

Following error will be thrown:

![Image](/images/screenshots/rails/redis/rails-expense-report-user-flow/expense_report_error.png)

Above error occurance is because of the absence of `index` action inside `Expenses Controller`. Addition of action is done in next chapter.

If you want to test the application from the downloaded source code [Exercise2-Complete.zip](/rails-code/expense-report-redis/Exercise2-complete.zip), please setup the application as described [here](/ruby/rails-tutorial/redis/redis-completers-guide.html) before continuing further.


<a class="button-plain" style="padding: 3px 15px;" href="/ruby/rails-tutorial/redis/rails-new-template-with-redis.html">Prev</a>   <a class="button-plain" style="padding: 3px 15px; float: right;" href="/ruby/rails-tutorial/redis/rails-redis-expense-user-flow.html">Next</a>
