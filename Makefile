SRC_DATA_PIPELINE = "data_pipeline"

all:
	echo "Nothing here yet."

.PHONY: dbt_compile dev extract_load deploy_models analytics

# TODO - remove this, do not depend on manifest.json
dbt_compile:
	cd $(SRC_DATA_PIPELINE) && dbt compile --profiles-dir profile --target $$ELT_ENVIRONMENT

dev:
	# Create virtualenv
	python3.10 -m venv .venv --upgrade-deps
	# Install Meltano and required plugins
	.venv/bin/pip3 install -r $(SRC_DATA_PIPELINE)/requirements-meltano.txt
	.venv/bin/meltano --cwd $(SRC_DATA_PIPELINE) install
	# Install dbt and required plugins
	.venv/bin/pip3 install -r $(SRC_DATA_PIPELINE)/requirements-dbt.txt
	.venv/bin/dbt deps --project-dir $(SRC_DATA_PIPELINE)
	.venv/bin/pip3 install -r $(SRC_DATA_PIPELINE)/requirements-gooddata.txt


extract_load:
	cd $(SRC_DATA_PIPELINE) && TARGET_SCHEMA=$$INPUT_SCHEMA_SFDC meltano --environment $$ELT_ENVIRONMENT run tap-salesforce $$MELTANO_TARGET

extract_load_sfdc:
	cd $(SRC_DATA_PIPELINE) && TARGET_SCHEMA=$$INPUT_SCHEMA_SFDC meltano --environment $$ELT_ENVIRONMENT run tap-salesforce $$MELTANO_TARGET

transform:
	cd $(SRC_DATA_PIPELINE) && dbt run --profiles-dir profile --target $$ELT_ENVIRONMENT
	cd $(SRC_DATA_PIPELINE) && dbt test --profiles-dir profile --target $$ELT_ENVIRONMENT
	# Invalidate GoodData caches after new data are delivered
	cd $(SRC_DATA_PIPELINE) && dbt-gooddata upload_notification

deploy_models: dbt_compile
	cd $(SRC_DATA_PIPELINE) && dbt-gooddata deploy_models $$GOODDATA_UPPER_CASE

deploy_analytics: dbt_compile
	cd $(SRC_DATA_PIPELINE) && dbt-gooddata deploy_analytics $$GOODDATA_UPPER_CASE
	cd $(SRC_DATA_PIPELINE) && dbt-gooddata test_insights

store_analytics:
	cd $(SRC_DATA_PIPELINE) && dbt-gooddata store_analytics

test_insights:
	cd $(SRC_DATA_PIPELINE) && dbt-gooddata test_insights

invalidate_analytics_caches:
	cd $(SRC_DATA_PIPELINE) && dbt-gooddata upload_notification
