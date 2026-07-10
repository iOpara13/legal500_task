{{
  config(
    materialized = 'table',
    tags=['staging']
    )
}}

with fmt_tbl as
( 
    SELECT
        UPPER(TRIM(submission_id)) as submission_id,
        UPPER(TRIM(firm_ref)) as firm_ref,
        UPPER(TRIM(practice_area_id)) as practice_area_id,
        TRY_CAST(TRIM(edition_year) AS INT) as edition_year,
        {{ standardise_submission_types('submission_type', 'submission_type_patterns') }} as submission_type,
        CASE 
            WHEN regexp_full_match(TRIM(submitted_by_email), '(?i)^\b[\.A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)[A-Z]{2,}\b$')
            THEN submitted_by_email
            ELSE 'Invalid Email'
        END as submitted_by_email,
        try_strptime(TRIM(submitted_at), '%Y-%m-%d %H:%M:%S') as submitted_at,
        TRY_CAST(TRIM(num_referees) AS INT) num_referees,
        LOWER(REPLACE(status, '_', ' ')) as status,
        try_strptime(TRIM(created_ts), '%Y-%m-%d %H:%M:%S') as created_ts,
        ROW_NUMBER() OVER (PARTITION BY submission_id ORDER BY created_ts DESC) as rn
    FROM {{ source('raw', 'submissions') }}
    WHERE UPPER(TRIM(firm_ref)) IN (SELECT DISTINCT UPPER(TRIM(firm_ref)) FROM {{ source('raw', 'firms') }})
    QUALIFY rn = 1
),
unioned_data as (
    SELECT
        submission_id,
        firm_ref,
        practice_area_id,
        edition_year,
        submission_type,
        submitted_by_email,
        submitted_at,
        num_referees,
        status,
        created_ts
    FROM fmt_tbl
    WHERE submitted_at <= (SELECT max(created_ts) FROM fmt_tbl)
    UNION ALL
    SELECT
        submission_id,
        firm_ref,
        practice_area_id,
        edition_year,
        submission_type,
        submitted_by_email,
        created_ts as submitted_at,
        num_referees,
        status,
        created_ts
    FROM fmt_tbl
    WHERE submitted_at > (SELECT max(created_ts) FROM fmt_tbl)
    
)
SELECT
    submission_id,
    firm_ref,
    practice_area_id,
    edition_year,
    submission_type,
    submitted_by_email,
    submitted_at,
    num_referees,
    status,
    created_ts,
    CURRENT_TIMESTAMP::TIMESTAMP AS etl_loaded_at
FROM unioned_data