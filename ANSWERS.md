# Answers to 5 & 6

## 5C

I chose to used Elementary's `elementary.schema_changes_from_baseline` to monitor schema drift as if this is a business critical application 
schemas should be pre-defined unless there a specific requirement to allow schema evolution. I did not fail `on_column_additions`
to avoid data loss when new columns are added but only fail when breaking changes are introduced.

## 5D

1. You can define exposures explicitly in a .yml to share with other team members or downstream teams of the lineage between data models, dashboards or clients. 
By setting the name, type, owner and what models they depend, your codebase becomes a single source of truth for data lineage. Main issue with exposures is that it must be
actively maintained. Data governance tools such as AWS Glue, Atlan have data crawlers that scan through the metadata of connected applications to provide lineage information. 
Providesvclear and searchable lineage (dbt's lineage gets a bit unwieldy in larger repos).

2. I'd create a slack webhook/teams notification for sending P2 alerts to a channel to be actioned by the team, examples would include:
  - Consistent casing in `post_status` - not a critical issue but may introduce some UI bugs in the application
  - `Submitted_by_emails` in wrong format and not caught by the regex
  For P1 issues - set up a trigger on the orchestrator, on pipeline failure after a retry it would trigger a Python script that triggers an SMS messaging service 
  such as Amazon SNS which can send an SMS on call engineer's mobile. P1 examples:
  - Minimum table row count in the `int__rankings` table falling lower than the floor set
  - Breaking schema changes on the rankings tables
  - Foreign key relationships to tables such as firms and practice areas from rankings breaking
  - SLA rules being violated.

  3. 
    Step 1 - Connect to warehouse and run `SELECT max(etl_loaded_at) FROM raw.rankings` to check if the raw tables have been updated. 
      If not, the Fivetran sync has failed and pipeline needs to be retriggered via Dagster.
    Step 2 - Clone the repo and configure your profiles.yml. Downloaded dependent packages and trigger `dbt debug` to ensure connection works then run `edt report`
    Step 3 - Check the Test Results tab for failing tests, click on it and view the results to investigate issues.
    Step 4 - Check codebase for latest commit before failure/find the offending commit, rollback changes and retrigger pipeline.
    Step 5 - Send necessary comms to stakeholders

  4. Adding schema validations/rowcount validation on the ingestion tool, stops bad data ever landing can be done directly in the software 
    or data can be landed in external storage and a script validates the data before transferring to raw.

  ## 6

  - RCA `Failure in test unique_stg__rankings_ranking_id` - Incremental sync reloaded a previous batch that overlap with records in raw, says +847 records vs 
  yesterday which is the exact number of records with duplicate IDs. To restore SLA and ensure this is self healing 
  add a ROW_NUMBER() OVER(PARTITION BY ranking_id ORDER BY updated_at DESC) rn statement to model and QUALIFY rn = 1. Quickest method to handle them is to delete
  but makes sense to just add deduplication step.
  - RCA `Failure in test not_null_stg__rankings_firm_ref` - Null values appearing in firm_ref column, to restore SLA and make this self healing add a filter/quarantine records
  where firm_ref is not in the reference firms table.
  - RCA `Warning in test accepted_values_stg__rankings_post_status__publish__draft__pending__trash` - New status values not in accepted values are passing to stg_rankings,
  warnings don't affect the SLA as they don't fail the pipeline - doesn't require immediate action. To make self healing a reference table for status can be created and the check
  can be changed to add a filter/quarantine records where status is not in the reference status table.
    
