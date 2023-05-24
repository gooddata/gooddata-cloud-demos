--
{% macro shorten_sensitive_field(column_name) -%}

    {%- if var('apply_compliance') == 'true'  -%}

       LEFT({{ column_name }},32)

    {%- else -%}

       {{ column_name }}

    {%- endif -%}

{%- endmacro %}