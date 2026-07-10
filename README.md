# legal500_task

Justifications for error severity can be found in the descriptions with the tests in the various schema.yml files
Justifications for derived flags can be found in the comments in the fct_firm_rankings.sql file

## Assumptions
- A ranking_tier of 0 is meant to represent unranked as it is not supposed to be null so setting nulls as 0
- The use of an incremental strategy/CDC is not being assessed. In a production env to protect against processing large amounts of data and slowing the pipeline down I would use an incremental strategy.
- When there is a duplicate on the grain chosen for int__rankings (edition_id, firm_name, practice_area, sub_practice_area) published records are prioritised. Thus published post status takes precedence over modified_ts in deduplication for int__rankings
- Volumes of data should not vary more than 8% of average - this would obviously be tweaked or right sized via collabarating with application team but its about half of what caused the incident.
- Volumes anomalies default should be left against 2 days, just checking against 1 day is too strict.
- Using the created_ts to deduplicate records in stg_submissions. There is a general pattern where the submitted_at = created_at my deduplication maintains that pattern. This pattern also helps in setting the submitted_at when it was placed in the future, thus my instinct to preserve it. In a real scenario I would check the source system or with an SME for confirmation of what is considered correct.
- Submission is not on the critical path for building the rankings table so it can have a separate tag to isolate pipelines.
- For runbook question I assume there'd be a link for connecting to dbt and setting up profile's which I would link to in a real runbook.

## Trade-offs
- Full table refreshes, fine for small data volumes this would cause performance overhead with large tables. Would also not be appropriate if FiveTran sync provides partial data, this would delete historical records.
- Row count floor is 400, each edition year has in the data has 481 and 484 (2024 and 2025 respectively). There it should be assumed a single year of data has at least 400 records, if there's less than 400 means that there is not even a full year of data available in the table which should cause a severity: 'error' warning. This 

## Things I'd Do With More Time
- Currently processing the whole table if I had more time I would set up a CDC process or incremental strategy. This would also affects monitoring for volume anomalies
- Talk to an SME if late arriving dimensions or early arriving facts was possible and would create a process for inserting firm references that dont exist in firm and setting them with default records. If this was not possible I would capture these failing records and would set out an alert to trigger the data producers. Assuming firm is a golden source and that is not possible, filtering them out at the moment.
- Speak with an SME to address large number of nulls in listing type, could be a useful column for controlling display behaviour in widget.


## Things I fixed in stg_submissions:
- Firm IDs accidentally have F9 which is not in table **Actual fix** deferred to keeping same behaviour as stg_rankings and filtering out invalid firm_refs. A potential fix could be change these missing cols to F0 based on a specific timestamp if it was agreed with the business this is a specific bug and it might take time to sort out in the source.
- Standardise submission_type entries {law_firm, FIRM, firm, Law Firm, law firm}, {individual, INDIVIDUAL}
- Capture valid email patterns and patterns like missing@, user@, plaintext, not-an-email, spaces in email@x.com are set to Invalid Email in submitted_by_email
- Submitted at has fields where they are in the future, set them to be the same as the created_ts field

## To Note
Error trying to run edr monitor states it needs a Slack webhook

<img width="548" height="401" alt="Error on running edr monitor" src="https://github.com/user-attachments/assets/f72261e4-137b-4718-bfaa-61dc445909e6" />

Successful run of edr report

<img width="1235" height="695" alt="Successfull run on running edr report" src="https://github.com/user-attachments/assets/bc2110ef-e70d-4515-8728-c9575dd168c4" />

