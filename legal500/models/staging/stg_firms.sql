{{
  config(
    materialized = 'table',
    tags=['staging']
    )
}}

SELECT
    firm_ref,
    firm_name,
    country,
    city,
    TRY_CAST(TRIM(established_year) AS INT) as established_year,
    TRY_CAST(TRIM(is_active) AS BOOLEAN) as is_active,
    try_strptime(TRIM(created_at), '%Y-%m-%d %H:%M:%S') as created_at,
    try_strptime(TRIM(updated_at), '%Y-%m-%d %H:%M:%S') as updated_at,
    CURRENT_TIMESTAMP::TIMESTAMP AS etl_loaded_at
FROM {{ source('raw', 'firms') }}
