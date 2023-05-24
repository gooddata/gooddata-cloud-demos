{{ config(
  indexes=[
    {'columns': ['lead_id'], 'unique': true}
  ]
) }}

-- TODO - incremental transform? By created_date or by lead_id?

with lead as (
  select *
  from {{ var("sfdc_input_schema") }}.lead
),

final as (
  select
    Id as lead_id,
    ConvertedContactId as converted_contact_id,
    {{ compliance_mask_email('email')}} as lead_email,
    CreatedDate as created_date,
    ConvertedOpportunityId as converted_opportunity_id,
    OwnerId as owner_id,
    Status as lead_status
  from lead
)

select * from final
