-- tdf_Scrap_Cost_Structure
-- 11 July 2022
-- Author: Tim Farmer
-- Scrap_Cost_Structure is approximating scrap weight for the current active
-- cost structure. The user models scrap costs by configuring a multiplier to
-- calculate a scrap rate.
-- Parameters: 
-- DECLARE
-- @Scrap_Factor DECIMAL(19,5)

IF @Scrap_Factor IS NULL
BEGIN
  SET @Scrap_Factor = .20
END

--------------------------------------------------------------------------------
-- Filter Configuration
-- Convert parameters to be sub-queried from a table variable
--------------------------------------------------------------------------------
DECLARE @Building VARCHAR(50)
   , @Delimiter VARCHAR(5) = ','
   , @Seperator VARCHAR(10) = ' REV:'

DECLARE @PARAMETERS TABLE
      (
         [Index] INT Identity(0, 1) PRIMARY KEY NOT NULL
         , Name VARCHAR(50) NOT NULL
         , Value VARCHAR(MAX) NOT NULL
      );

DECLARE @FILTERS TABLE
      (
         [Index] INT Identity(0, 1) PRIMARY KEY NOT NULL
         , Name VARCHAR(50) NOT NULL
         , Value VARCHAR(MAX) NOT NULL
      );

--INSERT @Parameters(Name,Value) SELECT 'PCN', @Delimiter + @PCN + @Delimiter
--IF @PCN != '' SET @PCN = (SELECT Value FROM @Parameters AS P WHERE Name = 'PCN')
--INSERT @Filters(Name, Value) SELECT 'PCN', LTRIM(RTRIM(SUBSTRING(@PCN, S.Number, CHARINDEX(@Delimiter, @PCN, S.Number ) - S.Number))) FROM Common_v_Split AS S WHERE S.Number <= LEN(@PCN) AND SUBSTRING(@PCN, S.Number - 1, 1) = @Delimiter

--------------------------------------------------------------------------------
-- Main Query

SELECT
  P.Plexus_Customer_No
  , CGM.Plexus_Customer_Code 
  , P.Part_Key
  , CASE Revision
      WHEN '' THEN Part_No
      WHEN '-' THEN Part_No
      WHEN ' ' THEN Part_No
      ELSE Concat(Part_No, ' REV: ', Revision)
    END AS PartNoRevision
  , Gross_Weight = MAX(A.Quantity)
  , Part_Weight = MAX(P.Weight)
  , Approximate_Scrap_Weight = (MAX(A.Quantity) - MAX(P.Weight))
  , @Scrap_Factor AS Scrap_Factor
  , Scrap_Rate = (MAX(A.Quantity) - MAX(P.Weight)) * @Scrap_Factor
  , Op.Operation_Code
  , Pop.Operation_No
FROM Part_V_Part_E  AS P
JOIN Part_V_BOM_E AS A
  ON A.Plexus_Customer_No = P.Plexus_Customer_No
  AND A.Part_Key = P.Part_Key
JOIN Part_v_Part_Operation_E AS Pop
  ON Pop.Plexus_Customer_No = P.Plexus_Customer_No
    AND Pop.Part_Operation_Key = A.Part_Operation_Key
JOIN Part_V_Operation_E AS Op
  ON Op.Plexus_Customer_No = P.Plexus_Customer_No
    AND Op.Operation_Key = Pop.Operation_Key
LEFT JOIN Plexus_Control_v_Customer_Group_Member AS CGM
  ON CGM.Plexus_Customer_No = P.Plexus_Customer_No
WHERE Op.Operation_Code = 'Stamping'
  AND A.Active = 1
  --AND (P.Plexus_Customer_No IN (SELECT Value FROM @Filters AS F WHERE Name = 'PCN') OR (P.Plexus_Customer_No LIKE @PCN + '%'))
GROUP BY
  P.Plexus_Customer_No
  , CGM.Plexus_Customer_Code 
  , P.Part_Key
  , P.Part_No
  , P.Revision
  , Pop.Operation_No
  , Op.Operation_Code
ORDER BY
  CGM.Plexus_Customer_Code  
  , P.Part_No
  , P.Revision

SELECT @@ROWCOUNT

RETURN;