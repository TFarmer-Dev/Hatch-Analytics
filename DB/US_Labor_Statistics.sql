USE [Plex_Facts]
GO
/****** Object:  StoredProcedure [Dbo].[US_Labor_Stats]    Script Date: 7/12/2022 12:13:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:  Tim Farmer
-- Create date: 16 June 2022
-- Description: Retrieve data older than the date given
-- =============================================
CREATE OR ALTER PROCEDURE [Dbo].US_Labor_Stats  
  -- Add the parameters for the stored procedure here
  --@RangeEnd DATETIME = NULL
  AS BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET Nocount ON;

DECLARE @Measures TABLE(
  Measure_Category varchar(128)
  , Measure varchar(128)
  , CountValue int
  , RateValue decimal(19, 2)
  , Suffix varchar(16)
  , YearValue nvarchar(16)
)

-- US Department of Labor and Statistics published rates
DECLARE @Measure_Category VARCHAR(100) = 'US Bureau of Labor and Statistics'
INSERT INTO @Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 25.7, '%', '2016')
INSERT INTO @Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 27.3, '%', '2017')
INSERT INTO @Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 28.8, '%', '2018')
INSERT INTO @Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 28.6, '%', '2019')
INSERT INTO @Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 41.8, '%', '2020')
INSERT INTO @Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 35.3, '%', '2021')


INSERT INTO @Measures VALUES(@Measure_Category, 'US Midwest', NULL, 43.2, '%', '2016')
INSERT INTO @Measures VALUES(@Measure_Category, 'US Midwest', NULL, 42.8, '%', '2017')
INSERT INTO @Measures VALUES(@Measure_Category, 'US Midwest', NULL, 45.0, '%', '2018')
INSERT INTO @Measures VALUES(@Measure_Category, 'US Midwest', NULL, 44.0, '%', '2019')
INSERT INTO @Measures VALUES(@Measure_Category, 'US Midwest', NULL, 58.8, '%', '2020')
INSERT INTO @Measures VALUES(@Measure_Category, 'US Midwest', NULL, 47.7, '%', '2021')

-- Reference: https://www.bls.gov/news.release/jolts.t16.htm

SELECT * FROM @Measures AS Measures

END;