---
title: Spring MVC with RabbitMQ
description: Spring MVC with RabbitMQ
tags:
    - spring
    - sts
    - rabbitmq
    - maven
    - tomcat
---
## Introduction
This is a guide for Java developers using the Spring framework and RabbitMQ message broker to build and deploy their apps on Cloud Foundry. It shows you how to set up and deploy Spring MVC application using RabbitMQ to Cloud Foundry.

## Prerequisites
Before you get started, you need the following:

+  A [Cloud Foundry account](http://cloudfoundry.com/signup).

+  The [vmc](http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html) Cloud Foundry command line tool.

+  A [Spring Tool Suite™ (STS)](http://www.springsource.org/spring-tool-suite-download) installation.

+  A [Cloud Foundry plugin for STS](http://docs.cloudfoundry.com/tools/STS/configuring-STS.html).

+  A [RabbitMQ 3.0.1](http://www.rabbitmq.com/) installation.


## Overview
The Spring Framework provides a comprehensive programming and configuration model for modern Java-based enterprise applications - on any kind of deployment platform. A key element of Spring is infrastructural support at the application level: Spring focuses on the "plumbing" of enterprise applications so that teams can focus on application-level business logic, without unnecessary ties to specific deployment environments. For more details visit [spring homepage](http://www.springsource.org/spring-framework).

In this tutorial, we are going to develop a simple messaging application using Spring MVC and RabbitMQ. We will access RabbitMQ using [Spring AMQP](http://www.springsource.org/spring-amqp). Spring AMQP provides high-level abstraction for sending and receiving messages.

<table class="spring-tutorial-index-table">
    <thead>
            <tr>
                <th>Exercise No</th>
                <th>Exercises</th>
                <th>Starters</th>
                <th>Complete</th>
            </tr>
    </thead>
    <tbody>
            <tr>
                <td>1</td>
                <td><a href='/spring/tutorials/springmvc-rabbitmq/spring-messaging-app-using-rabbitmq.html'>Create a Spring MVC Application using RabbitMQ</a></td>
                <td><a href='/code/tutorials/springmvc-rabbitmq/springmvc-messaging-rabbitmq_starter.zip'>springmvc-messaging-rabbitmq_starter.zip</a></td>
                <td><a href='/code/tutorials/springmvc-rabbitmq/springmvc-messaging-rabbitmq_complete.zip'>springmvc-messaging-rabbitmq_complete.zip</a></td>
            </tr>
    </tbody>
</table>

<a class="button-plain" style="padding: 3px 15px; float: right" href="/spring/tutorials/springmvc-rabbitmq/spring-messaging-app-using-rabbitmq.html">Next</a>
