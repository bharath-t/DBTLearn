Welcome to your new dbt project!

### Using the starter project

Try running the following commands:

- dbt run
- dbt test

### Resources:

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

### Notes:

Sources:

1. docs: https://docs.getdbt.com/docs/build/projects
2. commands: https://docs.getdbt.com/reference/commands/init
3. quickstart: https://docs.getdbt.com/guides/manual-install?step=1
4. crash course: https://www.youtube.com/watch?v=1fY1A8SRflI&list=PLc2EZr8W2QIBegSYp4dEIMrfLj_cCJgYA&index=2&ab_channel=SleekData
5. aws blogs:
   https://aws.amazon.com/blogs/big-data/implement-data-warehousing-solution-using-dbt-on-amazon-redshift/
   https://aws.amazon.com/blogs/big-data/build-and-manage-your-modern-data-stack-using-dbt-and-aws-glue-through-dbt-glue-the-new-trusted-dbt-adapter/

## Setup:

1. setup postgres locally
2. create a dir, venv, install dbt-core, adapter you need (postgres/snowflake/…)

```jsx
install: python -m pip install dbt-core dbt-ADAPTER_NAME
upgrade: python -m pip install --upgrade dbt-ADAPTER_NAME
specific version upgrade:
python -m pip install --upgrade dbt-core==0.19.0
python -m pip install dbt-core dbt-postgres
```

3. dbt init

## Notes:

1. project.yml: define which files exist where, apply some config at component/node/folder/tag level

2. profiles.yml - for local, create this in your home directory at ~/.dbt/profiles.yml. you can add multiple connections in single profile, set the target during dbt run

```jsx
dbt run --target dev  # Runs models against the dev schema
dbt run --target staging  # Runs models against the staging schema
```

3. source: input for your dataflow. tables where your elt process loads daily on a scheduled basis. create a yml file in models directory, define all your sources. can be referenced in other models using

```jsx
yml file:
sources:
  - name: data_source1
    tags: ["source_tag"]
    schema: public
    tables:
      - name: customers
      - name: orders

sql file:
{{ source('data_source1', 'customers') }}
```

4. seed: static csv file in seed directory to table.

   ```jsx
   dbt seed -- to load all seeds
   dbt seed —select model_name -- to load specific model
   ```

5. ref: to reference seeds / models

```jsx
{{ ref('cust_det') }} -- cust_det is csv seed file in seeds dir/ model
```

6. docs: mostly useful for lineage. we can put the json in s3, make it public and host a static website.

```jsx
dbt docs generate, dbt docs serve
```

7. test - inbuilt, custom

inbuilt:  `unique`, `not_null`, `accepted_values` and `relationships` . inbuilt checks are done in yml files at column definition. relationships mean each value in model column (cust_id) should be present in customers model id column.

```jsx
version: 2

models:
  - name: my_first_dbt_model
    description: "A starter dbt model"
    columns:
      - name: cust_id
        description: "The primary key for this table"
        data_tests:
          - unique
          - not_null
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned']
          - relationships:
              to: ref('customers')
              field: id
```

generic: create sql file in test/generic or macros folder, use it in data_tests above.

```jsx
sql file:
{% test custom_not_null(model, column_name) %}

    select *
    from {{ model }}
    where {{ column_name }} is null

{% endtest %}

yml file:
version: 2

models:
  - name: my_first_dbt_model
    description: "A starter dbt model"
    columns:
      - name: cust_id
        description: "The primary key for this table"
        data_tests:
          - custom_not_null
```

8. Macros: reusable sql function.

```jsx
sql:
{% macro get_cube(column_name) %}
    ({{ column_name }} * {{ column_name }} * {{ column_name }})
{% endmacro %}

call:
select qty, {{ get_cube('qty') }} from {{ ref('model_name') }};
```

9. jinja: loops, if, literals

```jsx
{% for /if ... %}
query
{% endfor/ endif %}
```

10. additional modules: dbt_utils

```jsx
add required package to packages.yml and run "dbt deps"
reference macros from installed package using packagename.macroname

packages.yml:
# You can check the latest version on https://hub.getdbt.com/
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1

usage:
dbt_utils.get_column_values(table=ref('my_first_dbt_model'), column='cust_state')
```

11. Snapshots:

create snapshots to identify scd. use strategy configuration (timestamp column or list of columns)

```jsx
sql: date column(updated_at), key column 'id'
{% snapshot orders_snapshot_timestamp %}

    {{
        config(
          target_schema='snapshots',
          strategy='timestamp',
          unique_key='id',
          updated_at='updated_at',
        )
    }}

    select * from {{ source('jaffle_shop', 'orders') }}

{% endsnapshot %}

sql: list of columns check
{% snapshot orders_snapshot_check %}

    {{
        config(
          target_schema='snapshots',
          strategy='check',
          unique_key='id',
          check_cols=['status', 'is_cancelled'],
        )
    }}

    select * from {{ source('jaffle_shop', 'orders') }}

{% endsnapshot %}

to create snapshot:
dbt snapshot
```

12. source freshness: check based on specific column how fresh the data is

```jsx
version: 2

sources:
  - name: jaffle_shop
    database: raw
    freshness: # default freshness
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    loaded_at_field: _etl_loaded_at


loaded_at_field is mandatory. warn_after/error_after or both can be provided.
to run: dbt source freshness
```

13. commonly used commands:

- dbt run — Runs the models you defined in your project
- dbt build — Builds and tests your selected resources such as models, seeds, snapshots, and tests
- dbt test — Executes the tests you defined for your project
- dbt compile - to check raw sql generated by jinja/dbt
- dbt build - build. check compilation errors.
- dbt debug - to test connection to db
- dbt deps - to install dependencies
- dbt source freshness - to check source freshness

14. Features tested:
    project.yml, profiles.yml, views, tables, seeds, sources, models, tags, docs, tests, macros, snapshots, additional modules (dbt_utils), source freshness
