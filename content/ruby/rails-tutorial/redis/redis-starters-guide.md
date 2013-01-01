---
title: Expense Report application with Rails and Redis
description: Application Setup from Starters Code
tags:
    - ruby
    - rails
---

##Introduction

This tutorial will teach you how to setup the application from the downloaded source code before proceeding to the rest of the chapters.

+ Ruby-1.9.2-p180 should be installed on your machine via `rvm`.

+ [Redis](http://redis.io/download) should be installed on your machine.

+ Because of the '.rvmrc' file in the application code, the particular ruby version with the gemset will be automatically used.

+ Install the gems specified in `Gemfile` by running the following command.

```bash
$ bundle install
```

+ If you get an error like `ExecJS::RuntimeUnavailable` while executing the above commands, then modify the below line in `Gemfile` from

```ruby
# gem 'therubyracer'
```

to

```ruby
gem 'therubyracer'
```

+ Now run the following command to install the gem and then execute the above mentioned commands to setup the database.

```bash
$ bundle install
```

+ That is all. Now follow the <a href="javascript:javascript:history.go(-1)">tutorial</a> to continue.