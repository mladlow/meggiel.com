---
title: "Using Liquibase With Aurora"
date: 2021-04-11T09:29:09-04:00
draft: true
---

# Notes

* Install Liquibase from website
  * Installs in /usr/local/opt
* Install PostgresQL Interactive Installer from https://www.postgresql.org/download/macosx/
  * Installs in /Library/PostgreSQL
  * I wound up losing the password and going to uninstall this :shrug:
  * Want to use Postgres.app instead
* Get PostgreSQL JDBC Driver from https://jdbc.postgresql.org/download.html
  * Put in ~/lib
* Configure Liquibase
```
changeLogFile: stablechangelog.sql
url: jdbc:postgresql://localhost:5432/stabledb
username: postgres
classpath: /Users/meggie/lib/postgresql-42.2.19.jar
```
  * Connect: `liquibase --password PROMPT generateChangeLog`
  * Added a table in there
  * At this point, `liquibase update` and `liquibase rollbackCount 1` both work
    as expected

## Liquibase

* Lots of different ways of structuring things
* This table is likely to be really simple and liquibase is probably overkill
  anyway, so just putting everything in a single file should be adequate
* Liquibase automatically (CI/CD mode via GH changes) seems like a pain, and not
  really how I want to spend my time
* It has `updateSQL` mode though!

### Steps

* Re-started with liquibase locally
* Created tag on empty table (initial)
* `liquibase --outputFile=update.sql updateSQL`

## RDS

* RDS HAS IAM AUTHENTICATION OPTION!!!
  * Would possible solve this whole problem, if stabledb user could authenticate
    via IAM
  * Aurora serverless doesn't support IAM database authentication :(
* Finally figured out data API via local terminal
```
% aws rds-data execute-statement --resource-arn <arn> --secret-arn <arn> --database <database name> --sql <sql>
CREATE USER <user> PASSWORD <pw>
CREATE DATABASE <database>
```
* To do this with a transaction
```
// Returns transactionID
aws rds-data begin-transaction --database <dbname> --secret-arn <arn> --resource-arn <arn>
// This didn't work -
// An error occurred (BadRequestException) when calling the ExecuteStatement operation: ERROR: relation "public.databasechangeloglock" does not exist
// Found https://stackoverflow.com/questions/62268654/running-updatesql-for-the-first-time-gives-database-returned-rollback-error-data
// so it may just not be supported
cat update.sql | xargs -0 aws rds-data execute-statement \
--resource-arn <arn> \
--secret-arn <arn> \
--transaction-id <transaction id> \
--database stabledb \ 
--sql
aws rds-data commit-transaction --secret-arn <arn> --resource-arn <arn> --transaction-id <trnsID>
```

## Java Lambda

* I made a basic lambda function with a java runtime (11) to try to run
  liquibase that way
* Installing Java on a mac is a PITA
* Once it's done, both `sam build` will work, as well as `mvn test` from inside
  the function directory, or `mvn -f HelloWorldFunction test`
