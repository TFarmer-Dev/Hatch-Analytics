USE [Plex_Accelerated]
GO

DROP PROCEDURE IF EXISTS [dbo].[DataRefresh-Stored_Procedure_Information]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:  Tim Farmer
-- Create date: 16 June 2022
-- Description: Retrieve data older than the date given
-- =============================================
CREATE PROCEDURE [dbo].[DataRefresh-Stored_Procedure_Information]
  -- Add the parameters for the stored procedure here
  --@RangeEnd DATETIME = NULL
  AS BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET Nocount ON

    -- Insert statements for procedure here

SELECT [Pcn]
      ,[Plexus_Customer_Code]
      ,[Created_Date]
      ,[Author_Pun]
      ,[Author_Last]
      ,[Author_First]
      ,[Last_Altered]
      ,[Last_Altered_Pun]
      ,[Editor_Last]
      ,[Editor_First]
      ,[Stored_Procedure_Name]
      ,[Specific_Name]
      ,[Stored_Procedure_Key]
      ,[Note]
      ,[Stored_Procedure_Text]
  FROM [dbo].[Stored_Procedure_Information_v]
  ORDER BY [Last_Altered] ASC

END
GO
