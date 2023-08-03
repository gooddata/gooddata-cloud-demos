{{ config(
  indexes=[
    {'columns': ['user_id'], 'unique': true}
  ]
) }}

with users as (
  select *
  from {{ var("sfdc_input_schema") }}.user
),

names as (
  select * from {{ var("sfdc_input_schema") }}.names
),

user_roles as (
  select *
  from {{ var("sfdc_input_schema") }}.userrole
),

final as (
  select
    U.Id as user_id,
    COALESCE(N.randomName,U.Name) as user_name,
    U.UserRoleId as user_role_id,
    U.ManagerId as manager_id,
    R.Name as user_role_name
  from users U
  left join user_roles R ON u.UserRoleId = R.Id
  left join names N ON U.Name = N.realName
  where U.isactive=true
)

select * from final
