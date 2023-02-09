USE [Plex_Facts]
GO
/****** Object:  StoredProcedure [dbo].[DataRefresh_Employee_Movement]    Script Date: 7/27/2022 6:31:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:  Tim Farmer
-- Create date: 16 June 2022
-- Description: Retrieve data older than the date given
-- =============================================
ALTER   PROCEDURE [dbo].[DataRefresh_Employee_Movement]  
  -- Add the parameters for the stored procedure here
  --@RangeEnd DATETIME = NULL
  AS BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET Nocount ON;

TRUNCATE TABLE [Dbo].[Employee_Movement_f]  

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

SET @max = (SELECT MAX(Id) FROM [Plex_Facts].[Dbo].[Employee_Movement_f] AS GLA)
IF @max IS NULL
BEGIN
  SET @max = 1001
  Dbcc Checkident ('[Plex_Facts].[Dbo].[Employee_Movement_f]', Reseed, @max)
END

SET @MinDate = (SELECT Top 1 COALESCE(Hire_Date, Rehire_Date, Contract_Hire_Date) AS Lastupdated FROM [Employee_Movement_f] AS EM ORDER BY EM.Table_Updated_Date DESC)
--SELECT @MinDate

SET @linkedserver = N'PLEX_VIEWS'
SET @openquery = N'SELECT * FROM OPENQUERY(' + @linkedserver + ','''
SET @sql_Select = N' SELECT
  Table_Updated_Date = GETDATE()
  , E.Plexus_Customer_No
  , Building = ISNULL(B.Plexus_Customer_Code, ''''Undefined'''')
  , PU.Plexus_User_No
  , E.Reports_To  
  , PU.User_ID
  , E.Customer_Employee_No
  , PU.Last_Name
  , PU.First_Name
  , E.Employee_Status
  , E.Contract_Worker
  , Hire_Date = CASE
      WHEN EA.Contract_Hire_Date IS NOT NULL AND
        EA.Contract_Hire_Date >= E.Hire_Date THEN NULL
      ELSE E.Hire_Date
    END
  , EA.Contract_Hire_Date
  , E.Rehire_Date
  , CASE
      WHEN E.Employee_Status != ''''Inactive'''' THEN NULL
      WHEN EA.Contract_Hire_Date IS NOT NULL AND EA.Contract_Hire_Date >= E.Hire_Date THEN NULL
      ELSE (SELECT TOP 1 T.Termination_Date AS Term_Date FROM Personnel_v_Termination AS T
            WHERE T.PUN = PU.Plexus_User_No AND T.Termination_Date IS NOT NULL AND T.Termination_Date >= E.Hire_Date
            ORDER BY T.Termination_Date DESC)
    END AS Term_Date
  , D.Department_Code
  , P.Position
  , CASE
      WHEN E.Pay_Type = '''''''' THEN ''''Undefined''''
      ELSE E.Pay_Type
    END AS Pay_Type
  , EA.Eligible_For_Salary
  , CASE
      WHEN S.Supplier_Code IS NOT NULL THEN ''''Temporary''''
      ELSE ET.Employee_Type
    END AS Employee_Type
  , S.Supplier_Code '
SET @sql_From = N'  FROM Personnel_v_Employee_E AS E

  JOIN Plexus_Control_v_Plexus_User_E AS PU
    ON PU.Plexus_User_No = E.Plexus_User_No

  RIGHT JOIN Common_v_Position_E AS P
    ON P.Plexus_Customer_No = PU.Plexus_Customer_No
    AND P.Position_Key = PU.Position_Key

  LEFT JOIN Personnel_v_Employee_Type_E AS ET
    ON ET.PCN = PU.Plexus_Customer_No
    AND ET.Employee_Type_Key = E.Employee_Type_Key

  LEFT JOIN Personnel_v_Employee_Attributes_E AS EA
    ON EA.PCN = PU.Plexus_Customer_No
    AND EA.PUN = PU.Plexus_User_No

  LEFT JOIN Common_v_Department_E AS D
    ON D.Plexus_Customer_No = PU.Plexus_Customer_No
    AND D.Department_No = PU.Department_No

  LEFT JOIN Plexus_Control_v_Customer_Group_Member AS B
    ON B.Plexus_Customer_No = PU.Plexus_Customer_No

  LEFT JOIN Common_v_Supplier_E AS S
    ON S.Plexus_Customer_No = PU.Plexus_Customer_No
    AND S.Supplier_No = E.Supplier_Key '
/*
OUTER APPLY (SELECT TOP (1) T.PUN, T.Termination_Date AS Term_Date FROM Personnel_v_Termination AS T
WHERE T.PUN = PU.Plexus_User_No AND T.Termination_Date IS NOT NULL AND T.Termination_Date >= E.Hire_Date
ORDER BY T.Termination_Date DESC) AS OAT '
*/

SET @sql_Where = N'  WHERE (
  P.Position != ''''System Resource'''' 
  AND E.Hire_Date IS NOT NULL
  AND E.Contract_Worker = 0
  )
  OR (
  P.Position != ''''System Resource'''' 
  AND EA.Contract_Hire_Date IS NOT NULL
  AND E.Contract_Worker = 1
  ) '   
--SET @sql_Group_By = N'  '
SET @sql_Order_By = N'  ORDER BY PU.Plexus_User_No  '')'

INSERT INTO [Plex_Facts].[Dbo].[Employee_Movement_f]
EXEC(@openquery + @sql_Select + @sql_From + @sql_Where + @sql_Order_By)

SELECT (@openquery + @sql_Select + @sql_From + @sql_Where + @sql_Order_By)
END
