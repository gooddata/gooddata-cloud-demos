{{ config(
  indexes=[
    {'columns': ['account_owner_id'], 'unique': true}
  ]
) }}

with users as (
  select *
  from {{ var("sfdc_input_schema") }}.user
),

names as (
  select * from {{ var("sfdc_input_schema") }}.names
),

final as (
  select
    Id as account_owner_id,
    N.randomName as account_owner_name,
    UserRoleId as account_owner_role_id
  from users U
  left join names N ON U.Name = N.realName
)

select * from final
