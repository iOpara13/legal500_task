{{
  config(
    materialized = 'view',
    tags=['staging']
    )
}}

SELECT
    practice_area_id,
    practice_group,
    practice_area,
    sub_practice_area,
    country,
    TRY_CAST(TRIM(is_active) AS BOOLEAN) as is_active,
    CURRENT_TIMESTAMP::TIMESTAMP AS etl_loaded_at
FROM {{ source('raw', 'practice_areas') }}
