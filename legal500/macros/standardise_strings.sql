{% macro standardise_submission_types(column_name, var_name, title_output=true) %}
    CASE
    {% for type, pattern in var(var_name).items() %}
        WHEN regexp_matches(LOWER(TRIM({{ column_name }})), '{{ pattern }}')
        {% if title_output %}
        THEN '{{ type | replace("_", " ") | title }}'
        {% else %}
        THEN '{{ type | replace("_", " ") }}'
        {% endif %}
    {% endfor %}
        ELSE {{ column_name }}
    END
{% endmacro %}