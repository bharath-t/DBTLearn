{# instead of null, could be any validation.eg: email check #}

{% test custom_not_null(model, column_name) %}

    select *
    from {{ model }}
    where {{ column_name }} is null

{% endtest %}