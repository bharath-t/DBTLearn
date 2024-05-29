{% snapshot my_first_dbt_model_timestamp %}

    {{
        config(
          target_schema='snapshots',
          strategy='check',
          unique_key='cust_id',
          check_cols=['status', 'is_cancelled'],
        )
    }}

    select * from {{ ref('my_first_dbt_model') }}

{% endsnapshot %}