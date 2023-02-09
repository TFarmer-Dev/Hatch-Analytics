USE [Plex_Facts]
GO
/****** Object:  StoredProcedure [Dbo].[DataRefresh_Locations]    Script Date: 7/12/2022 12:13:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:  Tim Farmer
-- Create date: 16 June 2022
-- Description: Retrieve data older than the date given
-- =============================================
CREATE OR ALTER PROCEDURE [Dbo].DataRefresh_Locations  
  -- Add the parameters for the stored procedure here
  --@RangeEnd DATETIME = NULL
  AS BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET Nocount ON;

TRUNCATE TABLE [Dbo].[Locations_f]  

DECLARE @lastupdate Datetime2
  , @rangestart Datetime2
  , @rangeend Datetime2
  , @linkedserver VARCHAR(MAX)
  , @openquery    VARCHAR(MAX)
  , @sql_Select   VARCHAR(MAX)
  , @sql_From     VARCHAR(MAX)
  , @sql_Where    VARCHAR(MAX)
  , @sql_Group_By VARCHAR(MAX)
  , @sql_Order_By VARCHAR(MAX)
  , @max          INT
  , @MinDate VARCHAR(MAX) = ''
  , @MaxDate VARCHAR(MAX) = (SELECT CONVERT(CHAR(8), GETDATE(), 112))

SET @max = (SELECT MAX(Id) FROM [Plex_Facts].[Dbo].[Locations_f] AS L)
IF @max IS NULL
BEGIN
  SET @max = 1001
  Dbcc Checkident ('[Plex_Facts].[Dbo].[Supervisors_f]', Reseed, @max)
END

--SET @MinDate = (SELECT Top 1 COALESCE(Hire_Date, Rehire_Date, Contract_Hire_Date) AS Lastupdated FROM [Employee_Absenses_f] AS EM ORDER BY EM.Table_Updated_Date DESC)
--SELECT @MinDate

SET @linkedserver = N'PLEX_VIEWS'
SET @openquery = N'SELECT * FROM OPENQUERY(' + @linkedserver + ','''
SET @sql_Select = N' SELECT Table_Updated_Date = GETDATE(), Plexus_Customer_No, Plexus_Customer_Code '
SET @sql_From = N' FROM Plexus_Control_v_Customer_Group_Member AS CGM '')'

--SET @sql_Where = N'  ' 
--SET @sql_Group_By = N'  '
--SET @sql_Order_By = N'  '')'

INSERT INTO [Plex_Facts].[Dbo].[Locations_f]
EXEC(@openquery + @sql_Select + @sql_From)
SELECT (@openquery + @sql_Select + @sql_From)

END
