CREATE SCHEMA IF NOT EXISTS raw;

CREATE SCHEMA IF NOT EXISTS elementary;

DROP TABLE IF EXISTS raw.rankings;


CREATE TABLE raw.rankings AS
SELECT *, CURRENT_TIMESTAMP::TIMESTAMP as etl_loaded_at FROM 
read_csv(
	"C:\Users\ian\Documents\legalrank-assessment\data\raw_rankings.csv"
	, all_varchar=True	
--	,timestampformat = "%Y-%m-%d %H:%M:%S"
--	,columns = {"ranking_id": VARCHAR, "edition_year": INT, 
--				"edition_id": VARCHAR, "firm_ref": VARCHAR, 
--				"practice_area_id": VARCHAR, "ranking_tier": VARCHAR, 
--				"tier_rank": VARCHAR, "ranking_type": VARCHAR, 
--				"post_status": VARCHAR, "publication_status": VARCHAR, 
--				"listing_type": VARCHAR, "commentary": VARCHAR,
--				"modified_ts": TIMESTAMP}
);



DROP TABLE IF EXISTS raw.firms;

CREATE TABLE raw.firms AS
SELECT *, CURRENT_TIMESTAMP::TIMESTAMP as etl_loaded_at FROM 
read_csv(
	"C:\Users\ian\Documents\legalrank-assessment\data\raw_firms.csv"
	, all_varchar=True
--	,timestampformat = "%Y-%m-%d %H:%M:%S",
--	,columns = {"firm_ref": VARCHAR, "firm_name": VARCHAR, 
--				"country": VARCHAR, "city": VARCHAR, 
--				"established_year": INT, "is_active": BOOLEAN, 
--				"created_at": TIMESTAMP, "updated_at": TIMESTAMP}
);

DROP TABLE IF EXISTS raw.submissions;

CREATE TABLE raw.submissions AS
SELECT *, CURRENT_TIMESTAMP::TIMESTAMP as etl_loaded_at FROM 
read_csv(
	"C:\Users\ian\Documents\legalrank-assessment\data\raw_submissions.csv"
	, all_varchar=True
--	,timestampformat = "%Y-%m-%d %H:%M:%S"
--	,columns = {"submission_id": VARCHAR, "firm_ref": VARCHAR, 
--				"practice_area_id": VARCHAR, "edition_year": INT, 
--				"submission_type": VARCHAR, "submitted_by_email": VARCHAR, 
--				"submitted_at": TIMESTAMP, "num_referees": INT, 
--				"status": VARCHAR, "created_ts": TIMESTAMP}
);

DROP TABLE IF EXISTS raw.practice_areas;

CREATE TABLE raw.practice_areas AS
SELECT *, CURRENT_TIMESTAMP::TIMESTAMP as etl_loaded_at FROM 
read_csv(
	"C:\Users\ian\Documents\legalrank-assessment\data\raw_practice_areas.csv"
	, all_varchar=True
--	,timestampformat = "%Y-%m-%d %H:%M:%S",
--	,columns = {"practice_area_id": VARCHAR, "practice_group": VARCHAR, 
--				"practice_area": VARCHAR, "sub_practice_area": VARCHAR, 
--				"country": VARCHAR, "is_active": BOOLEAN}
);
