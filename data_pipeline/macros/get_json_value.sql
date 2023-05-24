--
{% macro get_json_value(column_name) -%}

    {%- if target.type == "snowflake" -%}

        json_extract_path_text(properties,'{{ column_name }}') AS {{ column_name }}

    {%- else -%}

        json_extract_path_text(properties::json,'{{ column_name }}') AS {{ column_name }}

    {%- endif -%}

{%- endmacro %}