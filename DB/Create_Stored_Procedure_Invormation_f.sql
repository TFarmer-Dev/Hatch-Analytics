USE [Plex_Accelerated]
GO

/****** Object:  StoredProcedure [dbo].[DataRefresh-Stored_Procedure_Information]    Script Date: 9/1/2022 5:48:40 PM ******/
DROP PROCEDURE [dbo].[DataRefresh-Stored_Procedure_Information]
GO

/****** Object:  StoredProcedure [dbo].[DataRefresh-Stored_Procedure_Information]    Script Date: 9/1/2022 5:48:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:  Tim Farmer
-- Create date: 16 June 2022
-- Description: Retrieve data older than the date given
-- =============================================
/*
DROP PROCEDURE IF EXISTS [dbo].[DataRefresh-Stored_Procedure_Information]
*/

CREATE PROCEDURE [dbo].[DataRefresh-Stored_Procedure_Information]
  -- Add the parameters for the stored procedure here
  --@RangeEnd DATETIME = NULL
  AS BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET Nocount ON;

TRUNCATE TABLE dbo.Stored_Procedure_Information_f

DECLARE @linkedserver VARCHAR(MAX)
  , @openquery    VARCHAR(MAX)
  , @sql_Query   VARCHAR(MAX)
  , @sql_Select   VARCHAR(MAX)
  , @sql_From     VARCHAR(MAX)
  , @sql_Where    VARCHAR(MAX)
  , @sql_Group_By VARCHAR(MAX)
  , @sql_Order_By VARCHAR(MAX)
  , @max          INT
  , @PreMinDate Datetime
  , @MinDate VARCHAR(MAX) = ''
  , @MaxDate VARCHAR(MAX) = '''' + (SELECT FORMAT(GETDATE(), 'yyyy-MM-dd')) + ''''

SET @max = (SELECT MAX(Id) FROM Plex_Accelerated.Dbo.Stored_Procedure_Information_F AS S)
IF @max IS NULL
BEGIN
  SET @max = 1001
  Dbcc Checkident ('Plex_Accelerated.Dbo.Stored_Procedure_Information_F', Reseed, @max)
END

SELECT @MaxDate AS MaxDate

SET @PreMinDate = (SELECT TOP 1 A.Last_Altered AS Last_Altered FROM [Stored_Procedure_Information_f] AS A ORDER BY A.Last_Altered DESC)
--SET @PreMinDate = '01-01-1999'
SELECT @PreMinDate AS PreMinDate

SET @MinDate = '''' + (SELECT FORMAT(@PreMinDate, 'yyyy-MM-dd')) + ''''
SELECT @MinDate AS MinDate

SET @linkedserver = N'PLEX_VIEWS'
SET @openquery = N'SELECT * FROM OPENQUERY(' + @linkedserver + ','''
SET @sql_Select = N'    SELECT
                          Table_Updated_Date = GETDATE()
                          , S.Pcn
                          , Cgm.Plexus_Customer_Code
                          , S.Created_Date
                          , S.Author_Pun
                          , Author_Last = Pua.Last_Name
                          , Author_First = Pua.First_Name
                          , S.Last_Altered
                          , S.Last_Altered_Pun
                          , Editor_Last = Pum.Last_Name
                          , Editor_First = Pum.First_Name
                          , S.Stored_Procedure_Name
                          , S.Specific_Name
                          , S.Stored_Procedure_Key
                          , S.Note
                          , S.Stored_Procedure_Text '
SET @sql_From = N'      FROM Accelerated_Stored_Procedure_Information_E AS S
                        LEFT JOIN Plexus_Control_V_Customer_Group_Member AS Cgm
                        ON Cgm.Plexus_Customer_No = S.Pcn
                        LEFT JOIN Plexus_Control_V_Plexus_User_E AS Pua
                        ON Pua.Plexus_Customer_No = S.Pcn
                          AND Pua.Plexus_User_No = S.Author_Pun
                        LEFT JOIN Plexus_Control_V_Plexus_User_E AS Pum
                        ON Pum.Plexus_Customer_No = S.Pcn
                          AND Pum.Plexus_User_No = S.Last_Altered_Pun '
                       --WHERE FORMAT(Last_Altered, ''''yyyy-MM-dd'''') > ''' + @MinDate + ''' AND FORMAT(Last_Altered, ''''yyyy-MM-dd'''') <= ''' + @MaxDate + ''' '
--SET @sql_Where = N' WHERE Last_Altered > DateAdd(hh, -24, GETDATE()) '
SET @sql_Where = N' WHERE FORMAT(Last_Altered, ''''yyyy-MM-dd'''') > ''' + @MinDate + ''' AND FORMAT(Last_Altered, ''''yyyy-MM-dd'''') < ''' + @MaxDate + ''' '
SET @sql_Order_By = N' ORDER BY S.Last_Altered'')'

INSERT INTO Plex_Accelerated.Dbo.Stored_Procedure_Information_f
EXEC(@openquery + @sql_Select + @sql_From + @sql_Where + @sql_Order_By)
SELECT(@openquery + @sql_Select + @sql_From + @sql_Where + @sql_Order_By) AS Query

END
GO


