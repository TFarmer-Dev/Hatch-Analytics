-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tim Farmer
-- Create date: 16 June 2022
-- Description:	Retrieve data older than the date given
-- =============================================
CREATE OR ALTER PROCEDURE DataRefresh 
	-- Add the parameters for the stored procedure here
	--@RangeEnd DATETIME = NULL 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE
	  @RangeStart VARCHAR(1048)
	  , @LinkedServer VARCHAR(MAX)
	  , @OpenQuery VARCHAR(MAX)
	  , @SQL VARCHAR(MAX)	  
	  
	  
	  SET @RangeStart = (SELECT TOP 1 S.Last_Altered FROM Plex_Accelerated.dbo.Stored_Procedure_Information_f AS S
	                           WHERE S.Last_Altered > S.Table_Updated_Date ORDER BY S.Last_Altered DESC)

	  SET @LinkedServer = N'PLEX_VIEWS'
	  SET @OpenQuery = N'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''
      SET @SQL = N'
                 SELECT
                   Table_Updated_Date = CURRENT_TIMESTAMP
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
                   , S.Stored_Procedure_Text
                 FROM Accelerated_Stored_Procedure_Information_E AS S
                   LEFT JOIN Plexus_Control_V_Customer_Group_Member AS Cgm
                   ON Cgm.Plexus_Customer_No = S.Pcn
                   LEFT JOIN Plexus_Control_V_Plexus_User_E AS Pua
                   ON Pua.Plexus_Customer_No = S.Pcn
                     AND Pua.Plexus_User_No = S.Author_Pun
                   LEFT JOIN Plexus_Control_V_Plexus_User_E AS Pum
                   ON Pum.Plexus_Customer_No = S.Pcn
                     AND Pum.Plexus_User_No = S.Last_Altered_Pun
                 WHERE Last_Altered > GETDATE()'')
                '
				--
	  --SELECT @RangeStart AS [RangeStart], @LinkedServer AS [LinkedServer], @OpenQuery AS [OpenQuery], @SQL AS [SQL]

	IF @RangeStart IS NOT NULL
	BEGIN
      INSERT INTO Plex_Accelerated.dbo.Stored_Procedure_Information_f
      EXEC(@OPENQUERY+@SQL)
	END
END
GO

EXECUTE DataRefresh;
GO

--USE Plex_Accelerated;
--SELECT * FROM [Plex_Accelerated].[dbo].[Stored_Procedure_Information_f] AS S ORDER BY Last_Altered DESC;
--GO