{% macro generate_date_table(start_date, end_date) -%}

{%- if target.type == "snowflake" -%}

SELECT DATEADD(DAY, v.index, {{ start_date }})::DATE AS date
FROM LATERAL FLATTEN(SPLIT(SPACE(DATEDIFF(DAY, {{ start_date }}, {{ end_date }})), ' ')) v

{%- else -%}

SELECT d::DATE date
FROM GENERATE_SERIES(DATE {{ start_date }}, DATE {{ end_date }}, INTERVAL '1 day') t(d)

{%- endif -%}

{%- endmacro %}
