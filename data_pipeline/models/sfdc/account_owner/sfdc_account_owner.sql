{{ config(
  indexes=[
    {'columns': ['account_owner_id'], 'unique': true}
  ]
) }}

with users as (
  select *
  from {{ var("sfdc_input_schema") }}.user
),

final as (
  select
    Id as account_owner_id,
    Name as account_owner_name,
    UserRoleId as account_owner_role_id
  from users
)

select * from final
