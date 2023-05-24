--
{% macro compliance_mask_name(column_name) -%}

    {%- if var('apply_compliance') == 'true'  -%}

       MD5({{ column_name }})

    {%- else -%}

       {{ column_name }}

    {%- endif -%}

{%- endmacro %}