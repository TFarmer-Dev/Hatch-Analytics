DECLARE
	  @LinkedServer VARCHAR(MAX)
	  , @OpenQuery VARCHAR(MAX)
      , @SQL VARCHAR(MAX)
	  , @SQL_SELECT VARCHAR(MAX) 
	  , @SQL_FROM VARCHAR(MAX)
	  , @SQL_WHERE VARCHAR(MAX)    	  
	  , @SQL_GROUP_BY VARCHAR(MAX)
	  , @SQL_ORDER_BY VARCHAR(MAX)
      , @End_Open_Query VARCHAR(8) = ''')'

-- Linked Server configuration: DO NOT Change
--------------------------------------------------------------------
SET @LinkedServer = N'PLEX_VIEWS'
SET @OpenQuery = N'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''
--------------------------------------------------------------------

SET @SQL_SELECT = N'
SELECT DISTINCT TOP 500
  C.PCN 
  --, CA.Part_Key 
  , CA.Debit_Account_No 
  , CA.Credit_Account_No '

SET @SQL_FROM = N'FROM Common_v_Cost_Account_e AS C 
LEFT JOIN Common_v_Cost_Activity_e AS CA 
  ON CA.PCN = C.PCN 
    AND C.Posting_Type_Key = CA.Posting_Type_Key 
LEFT JOIN Common_v_Posting_Type AS PT 
  ON PT.Posting_Type_Key = CA.Posting_Type_Key 
LEFT JOIN Common_v_Cost_Sub_Type_e AS Cst 
  ON Cst.PCN = CA.PCN 
    AND Cst.Cost_Sub_Type_Key = CA.Cost_Sub_Type_Key 
LEFT JOIN Common_v_Cost_Type_e AS Ct 
  ON Ct.PCN = Cst.PCN 
    AND Ct.Cost_Type_Key = Cst.Cost_Type_Key '

SET @SQL_WHERE = 'WHERE C.PCN = 83677 
  AND PT.Active = 1 
  --AND Cst.Active = 1 
  AND PT.Description LIKE ''''Adjust%'''' '

SET @SQL_ORDER_BY = N' '
SET @SQL = N' SELECT
   C.PCN 
  , CA.Debit_Account_No 
  , CA.Credit_Account_No
FROM Common_v_Cost_Account_e AS C 
LEFT JOIN Common_v_Cost_Activity_e AS CA 
  ON CA.PCN = C.PCN 
    AND C.Posting_Type_Key = CA.Posting_Type_Key
LEFT JOIN Common_v_Posting_Type AS PT 
  ON PT.Posting_Type_Key = CA.Posting_Type_Key 	
WHERE C.PCN = 83677 
  AND PT.Active = 1 
  --AND Cst.Active = 1 
  --AND PT.Description LIKE ''''Adjust%''''
  ORDER BY CA.Debit_Account_No 
  , CA.Credit_Account_No '	

EXEC(@OpenQuery + @SQL + @End_Open_Query)
--EXEC(@OPENQUERY + @SQL_SELECT + @SQL_FROM + @SQL_WHERE + @End_Open_Query)






