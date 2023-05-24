--
{% macro extract_json_value_no_rename(json_column_name, field_name, data_type) -%}

    {%- if target.type == "snowflake" -%}

        CAST(json_extract_path_text(to_json(parse_json({{ json_column_name }})),'{{ field_name }}') AS {{ data_type }})

    {%- else -%}

        CAST(json_extract_path_text(to_json({{ json_column_name }}),'{{ field_name }}') AS {{ data_type }})

    {%- endif -%}

{%- endmacro %}