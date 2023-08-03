{{ config(
  indexes=[
    {'columns': ['lead_id'], 'unique': true}
  ]
) }}


with lead as (
  select *
  from {{ var("sfdc_input_schema") }}.lead
),

countries AS (
  SELECT *
                   FROM {{ var("sfdc_input_schema") }}.country_geo
),

final as (
  select
    Id as lead_id,
    ConvertedContactId as converted_contact_id,
    {{ compliance_mask_name('email')}} as lead_email,
    CreatedDate as created_date,
    ConvertedOpportunityId as converted_opportunity_id,
    OwnerId as owner_id,
    Status as lead_status,
    L.CountryCode as lead_country_code,
    C.Country_NAME as lead_country_name,
    C."LATITUDE"::VARCHAR  AS latitude,
    C."LONGITUDE"::VARCHAR AS longitude
  from lead L
  left join countries C ON L.CountryCode = C.COUNTRY_CODE
)


SELECT *
FROM final
