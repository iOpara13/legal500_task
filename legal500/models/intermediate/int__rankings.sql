{{
  config(
    materialized = 'table',
    tags=['staging', 'intermediate', 'rankings']
    )
}}
-- Grain is edition_id, firm_name, practice_area, sub_practice_area
-- I also saw on your website you show rankings for sub_practice_areas across a firm
with base as (
    SELECT 
        r.edition_id,
        r.edition_year,
        f.country,
        f.city,
        f.firm_name,
        f.established_year,
        p.practice_group,
        p.practice_area,
        p.sub_practice_area,
        r.ranking_tier,
        r.ranking_type,
        CASE
            WHEN lower(r.ranking_type) = 'firm recommended' AND r.ranking_tier = 0
            THEN 'not ranked'
            WHEN lower(r.ranking_type) = 'firm to watch' AND r.ranking_tier = 0
                AND lower(post_status) <> 'publish'
            THEN 'not ranked'
            ELSE 'ranked'
        END as ranking_decision_status,
        r.post_status,
        r.publication_status,
        r.listing_type,
        r.commentary,
        r.modified_ts as modified_ts,
        -- Assumption: Published post status takes precedence over modified_ts in deduplication
        -- If post_status is an indication of whether this has been posted to the API I would remove the case statement
        ROW_NUMBER() OVER (PARTITION BY edition_id, firm_name, practice_area, sub_practice_area
            ORDER BY
                CASE WHEN lower(r.post_status) = 'publish' THEN 1
                ELSE 2
                END, modified_ts
            ) as rn
    FROM {{ ref('stg_rankings') }} r
    LEFT JOIN {{ ref('stg_firms') }} f ON f.firm_ref = r.firm_ref
    LEFT JOIN {{ ref('stg_practice_areas') }} p ON p.practice_area_id = r.practice_area_id
    QUALIFY rn = 1
)
SELECT
    edition_id,
    edition_year,
    country,
    city,
    firm_name,
    established_year,
    practice_group,
    practice_area,
    sub_practice_area,
    ranking_tier,
    ranking_type,
    ranking_decision_status,
    post_status,
    publication_status,
    listing_type,
    commentary,
    modified_ts,
    CURRENT_TIMESTAMP::TIMESTAMP AS etl_loaded_at
FROM base