
with goals as (
  select *
  from {{ var("sfdc_input_schema") }}.goals
),

final as (
  select
    Quarter::TIMESTAMP as snapshot,
    UserID as UserID,
    RevenueGoal::NUMERIC(8,2) as RevenueGoal,
    ClosedGoal::NUMERIC(8,2) as ClosedGoal
  from goals
)

select * from final
