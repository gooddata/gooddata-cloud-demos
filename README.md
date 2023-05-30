# GoodData Demo project

Target of this demo is to show how GoodData fits into the cloud ecosystem and provide demo on your own Salesforce data. The aim is the experience to be as smooth as possible, still customisable.
There are two variants how the demo can work:
1. Using fully local experience - dockerised GoodData Cloud Native with included Postgres database
2. Cloud experience where GoodData Cloud is used together with your own Snowflake database

## Set up environment
Prepare and activate virtual environment for running tools. 

```shell
# Create virtualenv and install dependencies
make dev # Creates virtual env
# Activate virtualenv
source .venv/bin/activate
# Fill in missing configurations within .env file - there is .env.demo.local templated for local use-case
source .env.demo.local
```

## Run locally

In this scenario, the solution consists of GoodData Cloud Native run within Docker. GD CN comes with included Postgres database so we do not need to worry with additional package.
Data load from Salesforce is done using [Meltano](https://meltano.com/), for transformation [dbt](https://www.getdbt.com/) is used.
To make it work, you need to provide credentials for your Salesforce instance - see the point about env file. You can either use username/password and security token authentication or OAuth.

If you want to develop purely locally, use docker-compose:
```shell
docker-compose build
# Start GoodData
docker-compose up -d gooddata-cn-ce
# Wait 1-2 minutes to let GoodData to fully start
docker-compose up bootstrap_origins
```

## Run in cloud

In this scenario, the solution consists of GoodData Cloud (you can register yourself for [GoodData Trial](https://www.gooddata.com/)). As a data source Snowflake is used. To make the solution work, you will need access to Snowflake warehouse, have database ready and have permissions to fully work with the database for your user.
Data load from Salesforce is done using [Meltano](https://meltano.com/), for transformation [dbt](https://www.getdbt.com/) is used.
To make it work, you need to provide credentials for your Salesforce instance - see the point about env file.

### Set up environment
TODO: SQL script to set up database, file format
```SQL
CREATE DATABASE gd_test_demo;

CREATE OR REPLACE FILE FORMAT gd_test_demo.PUBLIC.MELTANO_FORMAT
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  ESCAPE = '\\'
  SKIP_HEADER = 0
  FIELD_OPTIONALLY_ENCLOSED_BY = '0x22'
  error_on_column_count_mismatch=false
;  
```
```shell
# Fill in missing configurations within .env file - there is .env.demo.local templated for local use-case
source .env.demo.cloud
```


## Run processes
### Running the pipeline
To run the pipeline directly from local environment, change the directory to pipeline root
```shell
cd data_pipeline
```

### Extract load
Each tap is loaded into separate DB schema.
TODO: There is currently dependencies clash between MEltano and dbt, there is workaround (only needed during initial run). We need to make sure MEltano and dbt have separate environments in future.
Prior to run Meltano for the first time:

```shell
pip install --upgrade snowplow-tracker
```

```shell
export TARGET_SCHEMA="${INPUT_SCHEMA_SFDC}"
meltano --environment $ELT_ENVIRONMENT run tap-salesforce $MELTANO_TARGET
# Run full refresh, refreshes data in target where 'last_modified_date' of source >= start_date of tap in meltano.yml
meltano --environment $ELT_ENVIRONMENT run tap-salesforce $MELTANO_TARGET --full-refresh
```

### Transform
The example transformation used in the example aims to demonstrate basic work with data and preparation for publishing data within GoodData workspace.
There is mechanism that can anonymise sensitive information within analytics - emails, names. This can be easily turned on or off by setting up variable "apply_compliance" (in "dbt_project.yml" configuration file).

TODO: There is currently dependencies clash between MEltano and dbt, there is workaround (only needed during initial run).  We need to make sure MEltano and dbt have separate environments in future.
Prior to run dbt for the first time:

```shell
pip install -Iv snowplow-tracker==0.10.0
```

```shell
# Run dbt
dbt run --profiles-dir profile --target $ELT_ENVIRONMENT
# Run full refresh, if you do breaking changes
dbt run --profiles-dir profile --target $ELT_ENVIRONMENT --full-refresh
```

### Generate GD LDM from dbt models
```shell
dbt-gooddata deploy_models $GOODDATA_UPPER_CASE
```

### Deliver analytics
```shell
dbt-gooddata deploy_analytics $GOODDATA_UPPER_CASE
```
At this point you can see your analytics in GD - either in http://localhost:3000 for the local use-case or within your GoodData Cloud trial.

### Store analytics prepared from UI
This way you can perserve end-user defined objects, store them in your repository and deploy anew as needed
```shell
# If you add analytics objects in UI and you want to sync it to this repo:
dbt-gooddata store_analytics
```

## Way Forward

Now you have basic idea on how GoodData can be used to visualise your data here's several examples of further use-cases:
- add custom objects from your SFDC and make the analytics targeted to your own users
- add further data sources to enrich the use-case or add other use-cases - you may want to add data from your Hubspot, Jira, Support system, Spreadsheets and more.
- productise your analytical solution - have separate environment for dev, staging, production orchestrated by automatical pipeline.
