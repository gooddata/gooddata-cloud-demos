# GoodData Demo project

Target of this demo is to show how GoodData fits into the cloud ecosystem and provide demo on your own Salesforce data. The aim is the experience to be as smooth as possible, still customisable.
![alt text](https://github.com/gooddata/gooddata-cloud-demos/blob/master/deployment_schema.png)

## Set up environment
Prepare and activate virtual environment for running tools.
(There may occur some dependecy errors that do not block solution operations. Please check final status of the jobs, if success is reported it usually means no action is needed)
```shell
# Create virtualenv and install dependencies
make dev # Creates virtual env
# Activate virtualenv
source .venv/bin/activate
```


## Run in GoodData Cloud

In the scenario, the solution consists of GoodData Cloud (you can register yourself for [GoodData Trial](https://www.gooddata.com/)). As a data source Snowflake is used. To make the solution work, you will need access to Snowflake warehouse, have database ready and have permissions to fully work with the database for your user.
Data load from Salesforce is done using [Meltano](https://meltano.com/), for transformation [dbt](https://www.getdbt.com/) is used.
To make it work, you need to provide credentials for your Salesforce instance - see the point about env file.

### Set up environment
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

## Run processes
### Fill in configuration
All necessary configuration is stored within configuration files. You will need to fill following section in ".env.demo.cloud" file:
```shell
# Sensitive secrets to connect to sources, must be entered by you, cannot be committed to git
export TAP_SALESFORCE_USERNAME="xxxx"
export TAP_SALESFORCE_PASSWORD="xxxx"
export TAP_SALESFORCE_SECURITY_TOKEN="xxxx"
# Alternatively, use OAuth
# export TAP_SALESFORCE_CLIENT_ID="xxxx"
# export TAP_SALESFORCE_CLIENT_SECRET="xxxx"
# export TAP_SALESFORCE_REFRESH_TOKEN="xxxx"
```
You can use either username/password authentication or OAuth one. The access token can be generated using [documentation](https://help.salesforce.com/s/articleView?id=sf.mc_pers_api_tokens_create.htm&type=5)

In addition to SFDC credentials as described above, you will also need to fill in credentials for you GoodDAta Cloud environment:
```shell
export GOODDATA_ENVIRONMENT_ID="development"
export GOODDATA_UPPER_CASE="--gooddata-upper-case"
export GOODDATA_HOST="https://xxxx.on.cloud.gooddata.com"
export GOODDATA_MODEL_IDS="sfdc"
export GOODDATA_TOKEN="xxxx"
```
[documentation](https://www.gooddata.com/developers/cloud-native/doc/cloud/getting-started/create-api-token/)
And also you Snowflake credentials:
```shell
export SNOWFLAKE_USER="xxxx"
export SNOWFLAKE_PASS="xxxx"
export SNOWFLAKE_DBNAME=gd_test
# Format of account in form: XX0000.<region>.aws
export SNOWFLAKE_ACCOUNT="xxxx"
export SNOWFLAKE_WAREHOUSE="xxxx"
```
Once the credentials are set up, you need to activate the variables:
```shell
# Fill in missing configurations within .env file - there is .env.demo.cloud templated for local use-case
source .env.demo.cloud
```
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
There are static files located in `data_pipeline/data` directory that are intended to enrich the data from Salesforce (there is file that is definyning Sales goals for Sales reps, there is a file defyning geo locations and file that can help you mask real user names). You can customise your files based on your needs.
Run the files ingestion:

```shell
export TARGET_SCHEMA=input_schema_csv
meltano --environment $ELT_ENVIRONMENT run tap-csv $MELTANO_TARGET --full-refresh
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
At this point you can see your analytics in GD - within your GoodData Cloud trial. Please note the analytics depends only on default Salesforce fields and therefore it is very basic, you can easily add your custom fields and enrich the analytics.

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
