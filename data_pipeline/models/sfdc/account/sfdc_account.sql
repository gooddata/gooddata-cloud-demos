{{ config(
  indexes=[
    {'columns': ['account_id'], 'unique': true}
  ]
) }}

with account as (
  select *
  from {{ var("sfdc_input_schema") }}.account
),

final as (
  select
    id as account_id,
    {{ compliance_mask_name('name')}} as account_name,
    type as account_type,
    OwnerId as account_owner_id
  from account
)

select * from final
