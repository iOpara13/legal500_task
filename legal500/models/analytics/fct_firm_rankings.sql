{{
  config(
    materialized = 'table',
    tags=['analytics', 'rankings']
    )
}}
with base as (
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
        -- Allows widget to easily set a filter for only active ranks
        CASE
            WHEN lower(publication_status) = 'active' THEN true
            ELSE false
        END active_ranking_flg,
        -- Allows widget to easily filter out archived ranks
        CASE
            WHEN lower(publication_status) = 'archived' THEN true
            ELSE false
        END archived_ranking_flg,
        -- Allows widget to easily filter for only the top tier firms
        CASE
            WHEN ranking_tier = 1 THEN true
            ELSE false
        END as top_firms_flg,
        -- Allows widget to easily filter for only the top tier firms to watch
        CASE
            WHEN ranking_tier = 1 and lower(ranking_type) = 'firm to watch' THEN true
            ELSE false
        END as top_firms_to_watch_flg,
        first_value(edition_year) OVER (PARTITION BY firm_name, practice_group, sub_practice_area ORDER BY edition_year) as latest_edition
    FROM {{ ref('int__rankings') }}
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
    active_ranking_flg,
    archived_ranking_flg,
    top_firms_flg,
    top_firms_to_watch_flg,
    CASE
        WHEN latest_edition = edition_year THEN true
        ELSE false
    END as latest_ranking_flg,
    modified_ts,
    CURRENT_TIMESTAMP::TIMESTAMP AS etl_loaded_at
FROM BASE