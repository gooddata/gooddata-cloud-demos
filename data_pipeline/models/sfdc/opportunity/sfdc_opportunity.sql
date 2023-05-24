{{ config(
  indexes=[
    {'columns': ['opportunity_id'], 'unique': true}
  ]
) }}

-- TODO - incremental transform? By created_date or by lead_id?

with oppty as (
  select *
  from {{ var("sfdc_input_schema") }}.opportunity
),

final as (
  select
    Id as opportunity_id,
    createddate as created_date,
    closedate as close_date,
    forecastcategoryname as forecast_category,
    {{ compliance_mask_name('name')}} as opportunity_name,
    OwnerId as opportunity_owner_id,
    accountid as account_id,
    stagename as opportunity_stage,
    amount::numeric as opportunity_amount
  from oppty
)

select * from final
