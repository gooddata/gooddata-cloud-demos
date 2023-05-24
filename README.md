# GoodData Demo project

Target of this demo is to show how GoodData fits into the cloud ecosystem and provide demo on your own Salesforce data.
There are two variants how the demo can work:
1. Using fully local experience - dockerised GoodData Cloud Native with included Postgres database
2. Cloud experience where GoodData Cloud is used together with your own Snowflake database


## Run locally

### Set up environment
```shell
# Create virtualenv and install dependencies
make dev # Creates virtual env
# Activate virtualenv
source .venv/bin/activate

# Fill in missing configurations within .env file - there is .env.demo.local templated for local use-case
source .env.demo.local
```
If you want to develop purely locally, use docker-compose:
```shell
docker-compose build
# Start GoodData
docker-compose up -d gooddata-cn-ce
# Wait 1-2 minutes to let GoodData to fully start
docker-compose up bootstrap_origins

# You can even run jobs in the docker way
docker-compose up extract_load
```

## Run in cloud

### Set up environment
For running Cloud demo you will need:
- GoodData Cloud environment ready (ie. GD Cloud trial TODO: link)
- Snowflake database ready
TODO: SQL script to set up database, file format
```shell
# Fill in missing configurations within .env file - there is .env.demo.local templated for local use-case
source .env.demo.local
```


## Run processes
### Running the pipeline
To run the pipeline directly from local environment, change the directory to pipeline root
```shell
cd data_pipeline
```

### Extract load
Each tap is loaded into separate DB schema.
```shell
export TARGET_SCHEMA="${INPUT_SCHEMA_SFDC}"
meltano --environment $ELT_ENVIRONMENT run tap-salesforce $MELTANO_TARGET
# Run full refresh, refreshes data in target where 'last_modified_date' of source >= start_date of tap in meltano.yml
meltano --environment $ELT_ENVIRONMENT run tap-salesforce $MELTANO_TARGET --full-refresh
```

### Transform
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
# If you add analytics objects in UI and you want to sync it to this repo:
dbt-gooddata store_analytics
```
