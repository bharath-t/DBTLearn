{# test will fail if the query returns any rows #}

select * from {{ ref('my_second_dbt_model' )}} 
where cust_name is null 
