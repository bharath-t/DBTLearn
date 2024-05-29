{# dbt utils macro use case: get list of all unique values in column #}
{# src: https://github.com/dbt-labs/dbt-utils/tree/1.1.1/#macros #}

{# option1: #}
{# {% set city_list = ['del','bom','hyd','blr'] %} #}

{# option 2: #}
{% set city_list = dbt_utils.get_column_values(table=ref('my_first_dbt_model'), column='cust_state') %}


{# handling "," at end of loop using if statement#}
select *,
{% for city in city_list %}
    {%- if not loop.last -%}
    case when cust_state = '{{ city }}' then 1 else 0 end as {{ city }}_flag,
    {% else %}
    case when cust_state = '{{ city }}' then 1 else 0 end as {{ city }}_flag
    {% endif %}
{% endfor %}

from {{ ref('my_first_dbt_model') }}
where cust_id = 1


{# not handling "," by adding dummy col after loop or keep some useful column at end #}
{# select *,
{% for city in city_list %}
case when cust_city = {{ city }} then 1 else 0 end as {{ city }}_flag,
{% endfor %}
1 as comma_handle_column

from {{ ref('my_first_dbt_model') }}
where cust_id = 1 #}
