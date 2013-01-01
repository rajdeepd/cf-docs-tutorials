---
title: Expense Report application with Rails and Redis
description: Creating, updating and deleting expenses in the application
tags:
    - ruby
    - rails
    - expense_user_flow
---

##Introduction

This chapter is a continuation of [chapter-2](/ruby/rails-tutorial/redis/rails-redis-expense-model.html). It explains how to add the funcionality to create, edit and delete expenses.

##Prerequisites

+ Should have completed [chapter 2](/ruby/rails-tutorial/redis/rails-redis-expense-model.html) - that dealt with addition of expense model for the application.


##Setup: Exercise3-Starter

If you are starting this chapter from the downloaded source code [Exercise3-Starter.zip](/rails-code/expense-report-redis/Exercise3-starter.zip), please setup the application as described [here](/ruby/rails-tutorial/redis/redis-starters-guide.html) before continuing with this tutorial.

##Subtopics

+ [Listing of expenses](#expense-listing)
+ [Creation of expense](#expense-creation)
+ [Updation of expense](#expense-updation)
+ [Deletion of expense](#expense-deletion)


## Expense listing

For listing the expense we need to fetch all the expenses from the database. Add the following action inside expense controller:

```ruby

  def index
     @expenses = Expense.all
   end

```

 An `index.html.erb` file should be created in `app/views/expense/`. Add the following code inside `index.html.erb`:

```rhtml
<div class="nav-btns">
  <%= link_to "New Expense",new_expense_path,:class => "btn-a" %>
  <%= link_to "Expenses",expenses_path,:class => "btn-a" %>
</div>
<% if @expenses.present? %>
    <table class="table-a mtop80">
      <thead>
      <tr>
        <td class="td-a">
          <h5 class="label-3">Date</h5>
        </td>
        <td class="td-b">
          <h5 class="label-3">Type</h5>
        </td>
        <td class="td-c">
          <h5 class="label-3">Description</h5>
        </td>
        <td class="td-c">
          <h5 class="label-3">Amount</h5>
        </td>
        <td  class="td-d">
          <h5 class="label-3">Action</h5>
        </td>
      </tr>
      </thead>
      <tbody>
      <% @expenses.each do |expense| %>
          <tr>
            <td>
              <h5 class="label-4"><%=  expense.date %></h5>
            </td>
            <td>
              <h5 class="label-4"><%= truncate(expense.expense_type, :length => 20) %></h5>
            </td>
            <td class="fixed-width">
              <h5 class="label-4">
                <%= truncate(expense.description, :length => 50) %>
              </h5>
            </td>
            <td class="fixed-width">
              <h5 class="label-4">
                <%= expense.amount %>
              </h5>
            </td>
            <td>
              <h5 class="label-4">
                <i class="alt-b label-6">
                  <%= link_to(edit_expense_path(expense.id), :class => "bg-edit-b") do %>
                      <img class="clip-b-img" src="<%= asset_path 'edit-a.png' %>">
                  <% end %>
                  <%= link_to get_cross_image.html_safe, expense_path(expense.id), :class => "bg-cross-b", :confirm => "Are you sure want to delete?", :method => :delete %>
                </i>
              </h5>
            </td>
          </tr>
      <% end %>
      </tbody>
    </table>
<% else %>
    <h1>No Expense added</h1>
<% end %>

```

In `app/helpers/application_helper.rb` add the following lines:-

```ruby
 def get_cross_image
    image_tag(asset_path("close.png"), :class => "cross-b-img")
  end
```

In `app/assets/javascripts/application.js` file add the following lines:-

```javascript

$(document).ready(function(){
    $('#date-field').datepicker({
        dateFormat: 'dd/mm/yy',
        maxDate: +0
    });
});

```



 The `index.html.erb` file will show all the persisted expenses. If no expense is present, then it will show "No expense added"


## Expense creation

Creating an expense consists of the following two steps:

##  STEP 1

Add an action `new` in the expense controller:

```ruby
def new

end
```

Corresponding to `new` action a `new.html.erb` file must be created inside `app/views/expense`.

Add the following lines inside the file:

```rhtml

<%= form_tag expenses_path :method => :post do%>
    <div class="action-a">
      <%= label_tag "description",'Description' ,:class => "label-name" %>
      <%= text_area_tag "expense[description]",'', :class => "textbox-a", :placeholder => "description" %>
    </div>

    <div class="action-a">
      <%= label_tag "amount", 'Amount',:class => "label-name" %>
      <%= text_field_tag "expense[amount]",'', :class => "textbox-a dd-b flt-left mleft0", :style => "width: 185px;", :placeholder => "Amount like 210.50" %>
    </div>

    <div class="action-a">
      <%= label_tag "expense_type", 'Expense Type',:class => "label-name" %>
      <%= select_tag "expense[expense_type]",options_for_select(['Health','Education','Sports','Travel'])%>
    </div>

    <div class="action-a">
      <%= label_tag "date", 'Generated on',:class => "label-name" %>
      <input type="text" name="expense[date]" placeholder="DD/MM/YY" id="date-field" class="textbox-a dd-b mleft0" style="width: 185px; cursor: pointer;" readonly="readonly" value="<%#= @expense.date %>" />
    </div>

    <%= submit_tag "Save", :class => "btn-a add-expense-btn" %>
<% end %>

```

This above form takes the description, amount, date and expense type and passes it to the create action inside.

## STEP 2
Add a create action inside the expense controller and add following lines into it:

```ruby

def create

 @expense = Expense.create(:description => params[:expense][:description],:amount => params[:expense][:amount],
    :expense_type => params[:expense][:expense_type],:date => params[:expense][:date])

    redirect_to expenses_path

end

```

The above action will create an expense and will redirect users to the page where all the expenses are listed.

## Expense updation

For the updation of expense we need to have two actions. First `edit`, in which we will be able to edit the attributes of expense and other will be `update` , in which the changes will be saved.

Add an `edit` action inside expense controller :

```ruby

  def edit
    @expense = Expense[params[:id]]
  end

```

Also create an `edit.html.erb` file inside `app/views/expenses/` and add following lines in the file:

```rhtml

<%= form_tag expense_path ,:method => :put  do%>
    <div class="action-a">
      <%= label_tag "description",'Description' ,:class => "label-name" %>
      <%= text_area_tag "expense[description]",@expense.description, :class => "textbox-a", :placeholder => "description" %>
    </div>

    <div class="action-a">
      <%= label_tag "amount", 'Amount',:class => "label-name" %>
      <%= text_field_tag "expense[amount]",@expense.amount, :class => "textbox-a dd-b flt-left mleft0", :style => "width: 185px;", :placeholder => "Amount like 210.50",:default => @expense.amount %>
    </div>

    <div class="action-a">
      <%= label_tag "expense_type", 'Expense Type',:class => "label-name" %>
      <%= select_tag "expense[expense_type]",options_for_select(['Health','Education','Sports','Travel'])%>

    </div>

    <div class="action-a">
      <%= label_tag "date", 'Generated on',:class => "label-name" %>
      <input type="text" name="expense[date]" placeholder="DD/MM/YY" id="date-field" class="textbox-a dd-b mleft0" style="width: 185px; cursor: pointer;" readonly="readonly" value="<%= @expense.date %>" />
    </div>

    <%= submit_tag "Save", :class => "btn-a add-expense-btn" %>
<% end %>

```

From the above form the new data for expense is taken and sent to `update` action inside expense controller with `PUT` request.

Now, next step is to add an update action in expense controller:

```ruby

def update
    @expense = Expense[params[:id]]
    @expense.description = params[:expense][:description]
    @expense.amount = params[:expense][:amount]
    @expense.expense_type = params[:expense][:expense_type]
    @expense.date = params[:expense][:date]
    if @expense.save
      redirect_to expenses_path
    else
      render "edit"
    end
  end

```

If updation is successful , users are redirected to  expense list page, else `edit` page is rendered.


## Expense deletion

In `index.html.erb` a delete link is present, which onclick sends a `DELETE` request to `destroy` action of the expense controller.

We need to add `destroy` action in the expense controller:

```ruby
def destroy
  expense = Expense[params[:id]]
  expense.delete
  redirect_to :back
end

```

In the above action the expense is found by `id` and deleted. After deletion of the expense, users are redirected back to the last page.

##Setup: Exercise3-Complete

If you want to test the application from the downloaded source code [Exercise3-Complete.zip](/rails-code/expense-report-redis/Exercise3-complete.zip), please setup the application as described [here](/ruby/rails-tutorial/redis/redis-completers-guide.html) before continuing with *check point*.

##Check Point

**Run the App Locally**

Execute the following command to run the app:

```bash
$ rails s
```

Users will be redirected to the expenses index page. On clicking the `New Expense` link, they will see a page as shown below:

![Image for creating new Expense](/images/screenshots/rails/redis/rails-expense-report-user-flow/expense_report_new.png)

Below image is a screen with some expenses in the index page:

![Image for Exense index page after creating Expenses](/images/screenshots/rails/redis/rails-expense-report-user-flow/expense_report_index.png)

<a class="button-plain" style="padding: 3px 15px;" href="/ruby/rails-tutorial/redis/rails-redis-expense-model.html">Prev</a>  <a class="button-plain" style="padding: 3px 15px; float: right;" href="/ruby/rails-tutorial/redis/rails-hosting-application-with-vmc.html">Next</a>
