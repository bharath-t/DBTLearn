/*
join between 2 source tables, 1 seed file
*/

{{ config(materialized='table', tags=["finance"]) }}


select a.cust_id,a.cust_name,b.order_id ,b.prod_id ,b.qty, c.cust_state, {{ get_cube('qty') }} as cubed
from {{ source('data_source1', 'customers') }} a 
inner join 
{{ source('data_source1', 'orders') }} b 
on a.cust_id = b.cust_id
inner join
{{ ref('cust_det') }} c
on a.cust_name = c.cust_name

