{{ config(
  indexes=[
    {'columns': ['contact_id'], 'unique': true}
  ]
) }}

-- TODO - incremental transform? By created_date or by lead_id?

with lead as (
  select *
  from {{ var("sfdc_input_schema") }}.contact
),

final as (
  select
    Id as contact_id,
    createddate as contact_created_date,
    {{ compliance_mask_email('email')}} as contact_email,
    CreatedDate as created_date,
    OwnerId as contact_owner_id,
    accountid as account_id
  from lead
)

select * from final
