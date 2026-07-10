{{
  config(
    materialized = 'table',
    tags=['staging', 'rankings']
    )
}}

with base as (
    SELECT 
        UPPER(TRIM(ranking_id)) as ranking_id,
        TRY_CAST(TRIM(edition_year) AS INT) as edition_year,
        UPPER(TRIM(edition_id)) as edition_id,
        UPPER(TRIM(firm_ref)) as firm_ref,
        UPPER(TRIM(practice_area_id)) as practice_area_id,
        -- Not using a ifnull after try_cast to intentionally cause a failure if nulls 
        -- still remain after modification means something else is happening in the col
        TRY_CAST(IFNULL(
            COALESCE(
                REPLACE(TRIM(LOWER(tier_rank)), 'tier_', ''), TRIM(ranking_tier)
            ), '0'
        ) as INT) as ranking_tier,
        -- Noticed mispelled ranking types, standardising string
        {{ standardise_submission_types('ranking_type', 'ranking_type_patterns', false) }} as ranking_type,
        LOWER(TRIM(post_status)) as post_status,
        publication_status,
        listing_type,
        commentary,
        try_strptime(TRIM(modified_ts), '%Y-%m-%d %H:%M:%S') as modified_ts,
        ROW_NUMBER() OVER (PARTITION BY ranking_id ORDER BY modified_ts DESC) as rn
    FROM {{ source('raw', 'rankings') }}
    -- Assuming invalid firms are firms not in firms table
    -- Thus assuming this the golden source and early arriving facts don't occur
    WHERE UPPER(TRIM(firm_ref)) IN (SELECT DISTINCT UPPER(TRIM(firm_ref)) FROM {{ source('raw', 'firms') }})
    QUALIFY rn = 1
)
SELECT 
    ranking_id,
    edition_year,
    edition_id,
    firm_ref,
    practice_area_id,
    ranking_tier,
    ranking_type,
    post_status,
    publication_status,
    listing_type,
    commentary,
    modified_ts,
    CURRENT_TIMESTAMP::TIMESTAMP AS etl_loaded_at
FROM base