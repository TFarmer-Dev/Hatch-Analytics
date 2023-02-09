USE [Plex_Facts]

DROP TABLE IF EXISTS [Plex_Facts].[Dbo].[Employee_Retention_Measures_f]
CREATE TABLE [Plex_Facts].[Dbo].[Employee_Retention_Measures_f]
(
  Measure_Category varchar(100)
, Measure varchar(100)
, CountValue int
, RateValue decimal(15, 2)
, Suffix varchar(5)
, YearValue nvarchar(100)
);