USE [Plex_Facts]
GO
/****** Object:  StoredProcedure [Dbo].[DataRefresh_Supervisors]    Script Date: 7/12/2022 12:13:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:  Tim Farmer
-- Create date: 16 June 2022
-- Description: Retrieve data older than the date given
-- =============================================
CREATE OR ALTER PROCEDURE [Dbo].DataRefresh_Supervisors  
  -- Add the parameters for the stored procedure here
  --@RangeEnd DATETIME = NULL
  AS BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET Nocount ON;

TRUNCATE TABLE [Dbo].[Supervisors_f]  

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

SET @max = (SELECT MAX(Id) FROM [Plex_Facts].[Dbo].[Supervisors_f] AS GLA)
IF @max IS NULL
BEGIN
  SET @max = 1001
  Dbcc Checkident ('[Plex_Facts].[Dbo].[Supervisors_f]', Reseed, @max)
END

--SET @MinDate = (SELECT Top 1 COALESCE(Hire_Date, Rehire_Date, Contract_Hire_Date) AS Lastupdated FROM [Employee_Absenses_f] AS EM ORDER BY EM.Table_Updated_Date DESC)
--SELECT @MinDate

SET @linkedserver = N'PLEX_VIEWS'
SET @openquery = N'SELECT * FROM OPENQUERY(' + @linkedserver + ','''
SET @sql_Select = N' SELECT DISTINCT
  Table_Updated_Date = GETDATE()
  , empl.Plexus_Customer_No
  , empl.Reports_To AS Supervisor_PUN
  , pu.Last_Name
  , pu.First_Name
  , empl.Plexus_User_No AS Employee_PUN '

SET @sql_From = N' FROM Personnel_v_Employee_e AS empl 
JOIN Plexus_Control_v_Plexus_User_e AS pu
  ON pu.Plexus_Customer_No = empl.Plexus_Customer_No
	AND pu.Plexus_User_No = empl.Reports_To'' )  '

--SET @sql_Where = N'  ' 
--SET @sql_Group_By = N'  '
--SET @sql_Order_By = N'  '')'

INSERT INTO [Plex_Facts].[Dbo].[Supervisors_f]
EXEC(@openquery + @sql_Select + @sql_From)

SELECT (@openquery + @sql_Select + @sql_From)
END
