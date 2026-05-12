-- Source DWH: Netezza-style sample DDL for branch region master
-- Lookup table that resolves Branch.REGION_CD to a human-readable region name + country.
-- Loaded once monthly via ETL (refresh_pattern=monthly).
CREATE TABLE CORE.BRANCH_REGION (
    REGION_CD VARCHAR(10) NOT NULL,
    REGION_NAME VARCHAR(40) NOT NULL,
    COUNTRY_CD CHAR(3) NOT NULL,
    UPDATED_AT TIMESTAMP,
    PRIMARY KEY (REGION_CD)
)
DISTRIBUTE ON (REGION_CD);
