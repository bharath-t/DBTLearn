{% macro get_cube(column_name) %}
    ({{ column_name }} * {{ column_name }} * {{ column_name }})
{% endmacro %}