USE [Plex_Facts]
GO
/****** Object:  StoredProcedure [dbo].[DataRefresh_Absenses]    Script Date: 7/27/2022 6:44:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:  Tim Farmer
-- Create date: 16 June 2022
-- Description: Retrieve data older than the date given
-- =============================================
ALTER   PROCEDURE [dbo].[DataRefresh_Absenses]  
  -- Add the parameters for the stored procedure here
  --@RangeEnd DATETIME = NULL
  AS BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET Nocount ON;

DECLARE @lastupdate Datetime2
  , @rangestart Datetime2
  , @rangeend Datetime2
  , @linkedserver VARCHAR(MAX)
  , @openquery    VARCHAR(MAX)
  , @sql_Query   VARCHAR(MAX)
  , @sql_Select   VARCHAR(MAX)
  , @sql_From     VARCHAR(MAX)
  , @sql_Where    VARCHAR(MAX)
  , @sql_Group_By VARCHAR(MAX)
  , @sql_Order_By VARCHAR(MAX)
  , @max          INT
  , @PreMinDate Datetime2
  , @MinDate VARCHAR(MAX) = ''
  , @MaxDate VARCHAR(MAX) = (SELECT FORMAT(GETDATE() - 1, 'yyyy-MM-dd'))

SET @max = (SELECT MAX(Id) FROM [Plex_Facts].[Dbo].[Employee_Absenses_f] AS A)
IF @max IS NULL
BEGIN
  SET @max = 1001
  Dbcc Checkident ('[Plex_Facts].[Dbo].[Employee_Absenses_f]', Reseed, @max)
END
SELECT @MaxDate AS MaxDate

SET @PreMinDate = (SELECT TOP 1 A.Pay_Date - 2 AS Last_Updated FROM [Employee_Absenses_f] AS A ORDER BY A.Pay_Date DESC)
SELECT @PreMinDate AS PreMinDate

SET @MinDate = '''''' + (SELECT FORMAT(@PreMinDate, 'yyyy-MM-dd')) + ''''''
SELECT @MinDate AS MinDate

SET @linkedserver = N'PLEX_VIEWS'
SET @sql_Query = N'SELECT * FROM(SELECT
  Table_Updated_Date = GETDATE()
  , puser.Plexus_Customer_No
  , puser.Plexus_User_No
  , puser.Last_Name
  , puser.First_Name
  , SUP_ID = 0
  , Pay_Date
  , clockin.Note
  , Description
  , ROW_NUMBER() OVER (
      PARTITION BY Pay_Date
      ORDER BY Creation_Date DESC
    ) AS Latest_Entry 
  FROM Plexus_Control_v_Plexus_User_e AS puser
  JOIN Personnel_v_Clockin_e AS clockin
    ON clockin.Plexus_Customer_No = puser.Plexus_Customer_No
    AND clockin.Plexus_User_No = puser.Plexus_User_No
  JOIN Personnel_v_Point_e AS point
    ON point.Clockin_Key = clockin.Clockin_Key
  JOIN Personnel_v_Point_Type_e AS ptype
    ON ptype.Point_Type_Key = point.Point_Type_Key 
WHERE FORMAT(clockin.Pay_Date, ''''yyyy-MM-dd'''') BETWEEN ' + @MinDate + ' AND ' + @MaxDate + ' 
  AND ptype.Active = 1
  AND ptype.Description IN (
  ''''Unexcused - Call''''
  , ''''Excused''''
  , ''''NCNS''''
  )
) AS composite
WHERE composite.Latest_Entry = 1 '

SET @openquery = N'SELECT * FROM OPENQUERY(' + @linkedserver + ',' + '''' + @sql_Query + ''')'
INSERT INTO [Plex_Facts].[Dbo].[Employee_Absenses_f]
EXEC(@openquery)
SELECT @openquery
END
