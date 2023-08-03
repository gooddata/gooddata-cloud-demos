{{ config(
  indexes=[
    {'columns': ['manager_id'], 'unique': true}
  ]
) }}

with users as (
  select *
  from {{ var("sfdc_input_schema") }}.user
),

mng_roles as (
  select id from {{ var("sfdc_input_schema") }}.userrole
  where (name ilike '%lead') or (name ilike '%exec')
),
names as (
  select * from {{ var("sfdc_input_schema") }}.names
),

final as (
  select
    Id as manager_id,
    N.randomName as manager_name,
    UserRoleId as manager_role_id
  from users U
  left join names N ON U.Name = N.realName
  where UserRoleId in (select id from mng_roles)
)

select * from final
