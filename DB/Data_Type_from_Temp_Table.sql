-- How to get schema data for a temporary table.
-- Sample OPENQUERY usage for a Linked Server called "PLEX_VIEWS"
-- SELECT * INTO #Tmp1 FROM (SELECT TOP 100 * FROM OPENQUERY(PLEX_VIEWS, 'SELECT TOP 100 Part_Key, Part_No, Revision FROM Part_v_Part_e AS p') AS Q) AS A
-- Following SP works great, exactly what is needed to get data types from a temporary table.
-- The trouble is output-ing the stored procedure to any table is not trivial.
-- EXEC master.sys.sp_help Tmp1
-- OR EXEC Sp_Help Tmp1



--SELECT DISTINCT Name FROM Sys.types AS T


DROP TABLE IF EXISTS Tmp1;
DROP TABLE IF EXISTS #Typez;

SELECT *
INTO
  Tmp1
FROM(
    SELECT
      Top(500) *
    FROM
    OPENQUERY
      (
        Plex_Views
        , N'
    SELECT
      Ppap.Plexus_Customer_No
      , Ppap_Key
      , Ppap_Part_Key = Ppap.Part_Key
      , P_Part_Key = P.Part_Key
      , Cp_Part_Key = Cp.Part_Key
      , Ppap_Part_No = Ppap.Part_No
      , P_Part_No = P.Part_No
      , Ppap_Part_Revision = Ppap.Part_Revision
      , P.Revision
      , Ppap.Customer_No
      , Ppap_Customer_Part_Key = Ppap.Customer_Part_Key
      , Cp_Customer_Part_Key = Cp.Customer_Part_Key
      , Ppap_Customer_Part_No = Ppap.Customer_Part_No
      , Cp_Customer_Part_No = Cp.Customer_Part_No
      , Ppap_Due_Date = Ppap.Due_Date
      , Ppap_Status
      , Ppap_Disposition = Pd.Description
      , Part_Name
      , Ppap.Drawing_No
      , Po_No
      , Ppap.Application
      , Ppap.Building_Key
      , Ppap_No
      , Ppap_Approval_Notification_Send_Date
      , Notify_Days_Before_Expiration
      , Apqp_Checklist_No
      , Program_Manager
      , Customer_Approval_Start_Date
      , Customer_Approval_End_Date
      , Customer_Approval_Quantity
      , Customer_Approval_Status_Key
      , Customer_Approval_Note
      , Internal_Approval_Start_Date
      , Internal_Approval_End_Date
      , Internal_Approval_Quantity
      , Internal_Approval_Status_Key
      , Internal_Approval_Note
      , Lead_Time
      , Submission_Date
      , Lead_Time_Days
    FROM Quality_V_Ppap_E AS Ppap
    LEFT JOIN Quality_V_Ppap_Disposition_E AS Pd
      ON Pd.Pcn = Ppap.Plexus_Customer_No AND Pd.Ppap_Disposition_Key = Ppap.Ppap_Disposition_Key
    LEFT JOIN Part_V_Part_E AS P
      ON P.Plexus_Customer_No = Ppap.Plexus_Customer_No AND P.Part_Key = Ppap.Part_Key
    LEFT JOIN Part_V_Customer_Part_E AS Cp
      ON Cp.Plexus_Customer_No = P.Plexus_Customer_No AND Cp.Customer_Part_Key = Ppap.Customer_Part_Key
    WHERE P.Part_Key IS NOT NULL'
      )
      AS Q
  ) AS A;

--SELECT * FROM Tmp1 AS T;

SELECT
 Id = ROW_NUMBER() OVER(ORDER BY T.Object_Id)
  , Tablez = T.Name
  , Columnz = C.Name
  , CASE Tu.Name
      WHEN 'nvarchar' THEN 'VARCHAR'
	  WHEN 'int' THEN 'INT'
	  WHEN 'float' THEN 'DECIMAL'
	  WHEN 'decimal' THEN 'DECIMAL'
	  WHEN 'bit' THEN 'BIT'
	  WHEN 'datetime' THEN 'DATETIME'
	  WHEN 'datetime2' THEN 'DATETIME2'
	  ELSE NULL
	END Typez
  , Max_Length = Tu.Max_Length
INTO #Typez
FROM Sys.Tables AS T
LEFT JOIN Sys.Columns AS C
  ON C.Object_Id = T.Object_Id
LEFT JOIN Sys.types AS Tu
  ON Tu.system_type_id = C.system_type_id
WHERE T.Name = 'Tmp1'
  AND Tu.Name != 'sysname'
--SELECT * FROM #Typez AS T


SELECT
  Id
  , Table_Name = Tablez
  , CASE
      WHEN Id > 1 THEN ' ,'
	  ELSE ''
	END Column_Prefix
  , Column_Suffix = Columnz
  , CASE 
      WHEN Typez = 'VARCHAR' AND Max_Length >= 8000 THEN Typez + '(MAX)'
	  WHEN Typez = 'DECIMAL' THEN Typez + '(19, 5)'
	  ELSE Typez + '(' + CAST(Max_Length AS VARCHAR) + ')'
	END AS Data_Type
FROM #Typez AS T



DROP TABLE IF EXISTS Tmp1;
DROP TABLE IF EXISTS #Typez;

RETURN;