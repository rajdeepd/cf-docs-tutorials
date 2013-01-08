---
title: Expense Reporting App with JPA using PostgreSQL
description: Create a Spring MVC App with JPA using PostgreSQL
tags:
    - spring
    - sts
    - tomcat
    - maven
    - jpa
    - postgresql
---

## Introduction
In this tutorial, you will use Spring MVC and PostgreSQL to create an Expense Reporting app and then deploy it on Cloud Foundry.
The Expense Reporting app will be used to create and manage expenses.

## Prerequisites
Before you begin this tutorial, you should:

1.  Be familiar with STS (Spring Tool Suite) or Eclipse.

### Setup: Exercise2-Starter
Import the source code from the downloaded folder Exercise2-Starter as follows. Open STS, Select **File > Import > Maven > Existing Maven Projects** and select Exercise2-Starter folder.

  ![maven-import-step1](/images/spring_tutorial/import-maven-project-step1.png)

  ![maven-import-step2](/images/spring_tutorial/import-maven-project-step2.png)

In the Expense Reporting App, a user can create an expense, view its status, edit it or delete it.

<img src="/images/spring_mongodb_tutorial/usecase.png" alt="normal-user-usecase.png" width="30%">

These expenses are created by the users and the data
is stored in PostgreSQL.

## Application Flow:
The below figure shows the runtime interaction of the application.

<img src="/images/spring_tutorial/cf-tutorials-postgresql.png" alt="sequence-flow" width="80%">


1.  User creates, deletes or updates an expense using the jsp/jQuery frontend.

2.  The http request goes to the `ExpenseController` which forwards it to the `ExpenseService`.

3.  The `ExpenseService` persists, deletes or updates the expense state in PostgreSQL using `EntityManager`.

In order to work with PostgreSQL and JPA following dependencies have been added in pom.xml.
```xml
 <dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-orm</artifactId>
	<version>${org.springframework-version}</version>
 </dependency>
 <dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-tx</artifactId>
	<version>${org.springframework-version}</version>
 </dependency>
 <dependency>
	<groupId>org.hibernate</groupId>
	<artifactId>hibernate-entitymanager</artifactId>
	<version>4.0.0.Final</version>
 </dependency>
 <dependency>
	<groupId>postgresql</groupId>
	<artifactId>postgresql</artifactId>
	<version>9.1-901.jdbc4</version>
 </dependency>
```

## **Step 1:** Adding Entities
The `@Entity` annotation indicates that the JavaBean is a persistent entity. Typically, an entity represents a table in a relational database, and each entity instance corresponds to a row in that table. The persistent state of an entity is represented through either persistent fields or persistent properties. These fields or properties use object-relational mapping annotations to map the entities and entity relationships to the relational data in the underlying data store.

By default, JPA takes a class name as a table name. If you want to store it under a different table name, provide the `@Table` annotation with the name property. Create a package for entities as `com.springsource.html5expense.model` and add the following entities `Expense`, `ExpenseType`, `State`.
```java
@Entity
@Table(name = "EXPENSE")
public class Expense {

    @Id
    @GeneratedValue
    private Long id;

    private String description;

    private Double amount;

    @Enumerated(EnumType.STRING)
    private State state = State.NEW;

    private Date expenseDate;

    private User user;

    @OneToOne
    private ExpenseType expenseType;
}
```

The `@Id` annotation specifies the primary key of the entity and the `@GeneratedValue` annotation tells JPA that the value in that field should map to the primary key and that the primary key should use an auto-incrementing value strategy. The `@OneToOne` annotation defines a single-valued association to another entity that has one-to-one multiplicity.

You can get the Entity classes [here](https://github.com/rajdeepd/cf-tutorials/tree/master/spring/springmvc-expensereport-postgres/src/main/java/com/springsource/html5expense/model).

## **Step 2:** Adding Services
`@Service` specifies a special component that provides the business services through interface. This annotation serves as a specialization of `@Component`, allowing for implementation classes to be autodetected through classpath scanning.

```java
public interface ExpenseService {
    Long createExpense(String description, ExpenseType expenseType, Date expenseDate, Double amount);

    Expense getExpense(Long expenseId);

    List<Expense> getAllExpenses();

    List<Expense> getPendingExpensesList();

    Expense changeExpenseStatus(Long expenseId, String state);

    void deleteExpense(Long expenseId);

    void updateExpense(Expense expense);
}
```
Business methods perform the following actions:

+ Create, Update or Delete an Expense.

+ Get all the expenses.

+ Update an expense's status.

* Create a package for service interfaces as `com.springsource.html5expense.services` and add `ExpenseService` and `ExpenseTypeService` interfaces which define the business methods.
You can get the service interfaces [here](https://github.com/rajdeepd/cf-tutorials/tree/master/spring/springmvc-expensereport-postgres/src/main/java/com/springsource/html5expense/services).

* Add the following service implementation classes `JpaExpenseService`, and `JpaExpenseTypeService` in the `com.springsource.html5expense.services` package. The EntityManager has been autowired. The `@Autowired` annotation is auto wired to the bean by matching data type. It is associated with a persistence context. A persistence context is a set of entity instances in which for any persistent entity identity there is a unique entity instance. Within the persistence context, the entity instances and their lifecycle are managed. The EntityManager API is used to create and remove persistent entity instances, to find entities by their primary key, and to query over entities. @PersistenceContext uses the EntityManagerFactory to create an EntityManager instance. We have marked the createExpense method with @Transactional annotation which will ensure the method is running in transaction.

```java
@Service
public class JpaExpenseService implements ExpenseService {

    private EntityManager entityManager;

    public EntityManager getEntityManager() {
        return entityManager;
    }

    @PersistenceContext
    public void setEntityManager(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @Transactional
    public Long createExpense(String description, ExpenseType expenseType, Date expenseDate,
            Double amount) {
        Expense expense = new Expense(description, expenseType, expenseDate, amount);
        entityManager.persist(expense);
        return expense.getId();
    }

    @Transactional
    public Expense getExpense(Long expenseId) {
        return entityManager.find(Expense.class, expenseId);
    }
}
```
You can get the service implementation classes [here](https://github.com/rajdeepd/cf-tutorials/tree/master/spring/springmvc-expensereport-postgres/src/main/java/com/springsource/html5expense/services).

Once you have added service implementation classes, ensure you aren't getting errors.

## **Step 3:** Adding the controller
The Controller is responsible for mapping requests. The `@RequestMapping` annotation is used to map requests onto specific handler methods. The following table explains the URLs we used in the ExpenseReport application:

<table class="spring-tutorial-index-table">
    <thead>
            <tr>
                <th>No</th>
                <th>HTTP Method</th>
                <th>URL Pattern</th>
                <th>Purpose</th>
            </tr>
    </thead>
    <tbody>
            <tr>
                <td>1</td>
                <td>GET</td>
                <td>/expenses</td>
                <td>Get all the expenses for the user</td>
            </tr>
            <tr>
                <td>2</td>
                <td>POST</td>
                <td>/expense</td>
                <td>Create a new expense</td>
            </tr>
            <tr>
                <td>3</td>
                <td>GET</td>
                <td>/expense/{id}</td>
                <td>Return an expense whose expenseid is passed</td>
            </tr>
            <tr>
                <td>4</td>
                <td>PUT</td>
                <td>/expense/{id}</td>
                <td>Update an expense whose expenseid is passed</td>
            </tr>
            <tr>
                <td>5</td>
                <td>DELETE</td>
                <td>/expense/{id}</td>
                <td>Delete an expense whose expenseid is passed</td>
            </tr>
    </tbody>
</table>

Create a package for Controllers as `com.springsource.html5expense.controllers` and add the `ExpenseController` class. The below method is used in ExpenseController to create a new expense. The `@ResponseBody` annotation indicates that this method return value should be bound to the web response body. We have added Jackson JSON marshaling library dependency in our project. Spring MVC detects this at startup and registers a `MappingJacksonHttpMessageConverter`, which will convert any java object to json strings.
```java
@ResponseBody
@RequestMapping(value = "/expense", method = RequestMethod.POST)
@ResponseStatus(value = HttpStatus.CREATED)
public Long createNewExpense(@RequestParam("description") String description,
		@RequestParam("amount") Double amount,
		@RequestParam("expenseTypeId") Long expenseTypeVal) {
	ExpenseType expenseType = expenseTypeService.getExpenseTypeById(expenseTypeVal);
	Long expenseId = expenseService.createExpense(description, expenseType, new Date(), amount);
	return expenseId;
}
```
In the method below, we have used `ModelMap`. It is a place where you can store key/value pairs to be used by the view in rendering a response.  It is through this context that you request specific information in the response.

```java
@RequestMapping(value = "/", method = RequestMethod.GET)
public String getExpenses(ModelMap model) {
     List<ExpenseType> expenseTypeList = expenseTypeService.getAllExpenseType();
     model.addAttribute("expenseTypeList", expenseTypeList);
     return "expensereports";
}
```
 In our controller, we have gathered some data about the expense types and made them available in the ModelMap using the autowired ExpenseTypeService reference. We can also use HTTP requests to store key/value pairs of data. To use HttpServletRequest, simply add another argument of type HttpServletRequest.

 Since html forms only support two methods: POST and GET. To use the DELETE and PUT methods, add `HiddenHttpMethodFilter` into your web.xml. Now use the Spring form tag with method as `delete` or use Ajax. It inspects the request and looks for a request parameter (usually called `_method`) that informs how it’s to transform the request.

```xml
<filter>
    <filter-name>hiddenHttpMethodFilter</filter-name>
    <filter-class>org.springframework.web.filter.HiddenHttpMethodFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>hiddenHttpMethodFilter</filter-name>
    <url-pattern>/</url-pattern>
    <servlet-name>appServlet</servlet-name>
</filter-mapping>
```

 You can get the controller class code [here](https://github.com/rajdeepd/cf-tutorials/tree/master/spring/springmvc-expensereport-postgres/src/main/java/com/springsource/html5expense/controllers).


## **Step 4:** Configuring the ExpenseReport application
In order to work with data from a PostgreSQL database, we need to obtain a connection to the database in order to define the dataSource bean. If your PostgreSQL server requires authentication, put the username and password of your PostgreSQL server in the dataSource bean. Define an interface `DataSourceConfiguration` in the `com.springsource.html5expense.config` package to get `dataSource`. Now implement this interface for your local datasource as `LocalDataSourceConfiguration` and use the `@Profile("local")` annotation.

```java
@Configuration
@Profile("local")
@PropertySource("/db.properties")
public class LocalDataSourceConfiguration implements DataSourceConfiguration {

    @Autowired
    private PropertyResolver propertyResolver;

    @Bean
    public DataSource dataSource() {
        SimpleDriverDataSource dataSource = new SimpleDriverDataSource();
        dataSource.setUrl(String.format("jdbc:postgresql://%s:%s/%s",
                 propertyResolver.getProperty("postgres.host"),
                 propertyResolver.getProperty("postgres.port"),
                 propertyResolver.getProperty("postgres.db.name")));
        dataSource.setDriverClass(org.postgresql.Driver.class);
        dataSource.setUsername(propertyResolver.getProperty("postgres.username"));
        dataSource.setPassword(propertyResolver.getProperty("postgres.password"));
        return dataSource;
    }
}
```
 Now implement `DataSourceConfiguration` for your Cloud Foundry datasource as `CloudDataSourceConfiguration` and use `@Profile("cloud")` annotation. To use the Cloud Foundry API, add the following dependency in your `pom.xml`:
```xml
<dependency>
   <groupId>org.cloudfoundry</groupId>
   <artifactId>cloudfoundry-runtime</artifactId>
   <version>0.8.2</version>
</dependency>
```

```java
@Configuration
@Profile("cloud")
public class CloudDataSourceConfiguration implements DataSourceConfiguration {

    private CloudEnvironment cloudEnvironment = new CloudEnvironment();

    @Bean
    public DataSource dataSource() {
        Collection<RdbmsServiceInfo> psqlServiceInfo = cloudEnvironment.
                                   getServiceInfos(RdbmsServiceInfo.class);
        RdbmsServiceCreator dataSourceCreator = new RdbmsServiceCreator();
        return dataSourceCreator.createService(psqlServiceInfo.iterator().next());
    }
}
```

 Now we have declared two datasources, one for your local environment and another for the Cloud Foundry environment. To avoid switching back from one database to another, we can make the selected profile active. Based on the active profile, only that particular bean should be created. We can select the active profiles based on the environment, create a class called `ExpenseReportAppContextInitializer` in `com.springsource.html5expense.web` and implement `ApplicationContextInitializer`. The ApplicationContextInitializer is used to set active profiles and register custom property sources.

```java
public class ExpenseReportAppContextInitializer implements
        ApplicationContextInitializer<AnnotationConfigWebApplicationContext> {

    private CloudEnvironment cloudEnvironment = new CloudEnvironment();

    private boolean isCloudFoundry() {
        return cloudEnvironment.isCloudFoundry();
    }

    @Override
    public void initialize(AnnotationConfigWebApplicationContext applicationContext) {
        String profile = "local";
        if (isCloudFoundry()) {
            profile = "cloud";
        }
        applicationContext.getEnvironment().setActiveProfiles(profile);
        applicationContext.refresh();
    }
}
```

The application needs to be configured in order to make it ready to deploy. Add the following classes: `ComponentConfig`, `WebConfig` in the `com.springsource.html5expense.config` package. The ComponentConfig class has been marked with a `@Configuration` annotation to configure beans. This is an alternative to XML configuration for bean definition. We can pass this class as an argument to the Spring container as a source for bean creation.
```java
@Configuration
@EnableTransactionManagement
@ComponentScan(basePackageClasses = {JpaExpenseService.class,
        ExpenseController.class, Expense.class })
public class ComponentConfig {

    @Autowired private DataSourceConfiguration dataSourceConfiguration;

    @Bean
    public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
        LocalContainerEntityManagerFactoryBean emfb =
                     new LocalContainerEntityManagerFactoryBean();
        emfb.setJpaVendorAdapter(jpaAdapter());
        emfb.setDataSource(dataSourceConfiguration.dataSource());
        emfb.setJpaPropertyMap(jpaPropertyMap());
        emfb.setJpaDialect(new HibernateJpaDialect());
        emfb.setPackagesToScan(new String[]{Expense.class.getPackage().getName()});
        return emfb;
    }

    @Bean
    public JpaVendorAdapter jpaAdapter() {
        HibernateJpaVendorAdapter hibernateJpaVendorAdapter = new HibernateJpaVendorAdapter();
        hibernateJpaVendorAdapter.setShowSql(true);
        hibernateJpaVendorAdapter.setDatabase(Database.POSTGRESQL);
        hibernateJpaVendorAdapter.setShowSql(true);
        hibernateJpaVendorAdapter.setGenerateDdl(true);
        return hibernateJpaVendorAdapter;
    }

    public Map<String, String> jpaPropertyMap() {
        Map<String, String> map = new HashMap<String, String>();
        map.put(org.hibernate.cfg.Environment.HBM2DDL_AUTO, "create");
        map.put(org.hibernate.cfg.Environment.HBM2DDL_IMPORT_FILES, "import.sql");
        map.put("hibernate.c3p0.min_size", "5");
        map.put("hibernate.c3p0.max_size", "20");
        map.put("hibernate.c3p0.timeout", "360000");
        map.put("hibernate.dialect", "org.hibernate.dialect.PostgreSQLDialect");
        return map;
    }
}

```

 To declare a bean, simply annotate a method with the `@Bean` annotation in your config class. This method is used to register a bean definition within an ApplicationContext of the type specified as the method's return value. By default, the bean name will be the same as the method name.
   
To enable declarative transaction management, add a `@EnableTransactionManagement` annotation to the ComponentConfig class. The `@EnableTransactionManagement` annotation is responsible for Spring's annotation-driven transaction management capability, similar to the support found in Spring's <tx:*> XML namespace. This annotation will search for a bean of type PlatformTransactionManager registered in the context so define a bean `PlatformTransactionManager` in ComponentConfig class.
```java
@Bean
public PlatformTransactionManager transactionManager() {
    final JpaTransactionManager transactionManager = new JpaTransactionManager();
    transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());
    Map<String, String> jpaProperties = new HashMap<String, String>();
    jpaProperties.put("transactionTimeout", "43200");
    transactionManager.setJpaPropertyMap(jpaProperties);
    return transactionManager;
}
```

Next, configure the components using `@ComponentScan`. It will Configure component scanning directives for use with `@Configuration` classes and provides parallel support with Spring XML's `<context:component-scan>` element, passing a basePackageClasses() or basePackages() value.

  Create a new file `import.sql` in `src/main/resources` and add sql statements.
```sql
insert into expenseType(id,name) values(nextval('hibernate_sequence'),'MEDICAL');
insert into expenseType(id,name) values(nextval('hibernate_sequence'),'TRAVEL');
insert into expenseType(id,name) values(nextval('hibernate_sequence'),'TELEPHONE');
insert into expenseType(id,name) values(nextval('hibernate_sequence'),'GYM');
insert into expenseType(id,name) values(nextval('hibernate_sequence'),'EDUCATION');
```

  To execute these statements automatically in the database when the app starts, we have set these two properties in the entityManagerFactory bean.
```java
map.put(org.hibernate.cfg.Environment.HBM2DDL_AUTO, "create");
map.put(org.hibernate.cfg.Environment.HBM2DDL_IMPORT_FILES, "import.sql");
```

  Modify the `db.properties` file properties database username, password, and database name according to your local database.

  To load ComponentConfig class as part of contextConfigLocation, add contextClass as `AnnotationConfigWebApplicationContext` and `contextConfigLocation` as
com.springsource.html5expense.config. Then set `contextInitializerClasses` as ExpenseReportAppContextInitializer.
```xml
<context-param>
    <param-name>contextInitializerClasses</param-name>
    <param-value>
       com.springsource.html5expense.web.ExpenseReportAppContextInitializer
    </param-value>
</context-param>
<context-param>
    <param-name>contextClass</param-name>
    <param-value>
      org.springframework.web.context.support.AnnotationConfigWebApplicationContext
    </param-value>
</context-param>
<context-param>
   <param-name>contextConfigLocation</param-name>
   <param-value>com.springsource.html5expense.config</param-value>
 </context-param>
```

You can get the Config classes [here](https://github.com/rajdeepd/cf-tutorials/tree/master/spring/springmvc-expensereport-postgres/src/main/java/com/springsource/html5expense/config).

## **Step 5:** Adding View Files
The ExpenseReport app service is ready. To get users to interact with it, it needs a user interface. To resolve the Controller's return `view` value, we have defined InternalViewResolver.

```java
@Bean
public InternalResourceViewResolver internalResourceViewResolver() {
     InternalResourceViewResolver internalResourceViewResolver =
                           new InternalResourceViewResolver();
     internalResourceViewResolver.setPrefix("/WEB-INF/views/");
     internalResourceViewResolver.setSuffix(".jsp");
     return internalResourceViewResolver;
}
```

The application requires `expensereports.jsp` to be added in the `webapp/WEB-INF/view` folder. You can download it from [here](https://github.com/rajdeepd/cf-tutorials/tree/master/spring/springmvc-expensereport-postgres/src/main/webapp/WEB-INF/views).

## Check Point
1. Select your project, drag it down and drop into your VMware vFabric tc server listed in the bottom left Server window.

2. Select VMware vFabric tc server and click the start button to run the server.

3. Once the server starts, open your browser and enter the application url : `http://localhost:8080/html5expense/`. Click on New Expense to create a new expense.  
  ![local_deploy.png](/images/spring_tutorial/local.png)

4. Go to your PostgreSQL client and give the command **\dt**. It will list all the tables in the database so you can check that new tables have been created for the Entities.
```sql
postgres=# \dt
                 List of relations
 Schema |          Name          | Type  |  Owner
--------+------------------------+-------+----------
 public | expense                | table | postgres
 public | expensetype            | table | postgres
(2 rows)

```

## Complete Application Code
If you are getting any errors, download the Exercise2-Complete code and import into STS.

## Deploying to Cloud Foundry
* To learn more about deploying Spring App with PostgreSQL to Cloud Foundry, please refer [here](/spring/tutorials/springmvc-jpa-postgres/springmvc-app-with-postgresql-deployment-to-cloudfoundry.html).

<a class="button-plain" style="padding: 3px 15px;" href="/spring/tutorials/springmvc-jpa-postgres/springmvc-template-project.html">Prev</a><a class="button-plain" style="padding: 3px 15px; float: right" href="/spring/tutorials/springmvc-jpa-postgres/springmvc-app-with-postgresql-deployment-to-cloudfoundry.html">Next</a>

