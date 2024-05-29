{# source: https://docs.getdbt.com/guides/debug-schema-names?step=2 #}
{# node is the model itself.its a dict with props resource_type, resource_name. #}
{# we are modifying inbuild dbt macro here, by default it takes target props (schema, db) from profiles.yml #}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}

    {% elif node.resource_type == 'seed' %}
        {{ custom_schema_name | trim }}

    {% elif target.name == 'prod' %}
        prod_{{ custom_schema_name | trim }}

    {%- else -%}
        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}


{# create this test bloc either here or separate file in macros or tests/generic folder #}

{# {% test custom_not_null(model, column_name) %}

    select *
    from {{ model }}
    where {{ column_name }} is null

{% endtest %} #}