--
{% macro compliance_mask_email(column_name) -%}

    {%- if var('apply_compliance') == 'true'  -%}

       MD5(left({{ column_name }}, POSITION('@' IN {{ column_name }})-1)||'x')||'@'||right({{ column_name }}, length({{ column_name }})-POSITION('@' IN {{ column_name }}))

    {%- else -%}

       {{ column_name }}

    {%- endif -%}

{%- endmacro %}