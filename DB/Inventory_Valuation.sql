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

SET @LinkedServer = N'PLEX_VIEWS'
SET @OpenQuery = N'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''
SET @SQL_SELECT = N'SELECT TOP 500 * '
SET @SQL_FROM = N'FROM Common_V_Cost_Account_E AS CA '
SET @SQL_WHERE = N' '
SET @SQL_GROUP_BY = N' '
SET @SQL_ORDER_BY = N' '
--SET @SQL = 'SELECT Plexus_Customer_No, Part_No, Revision, Name, Weight, Part_Status FROM Part_V_Part_E AS P WHERE Plexus_Customer_No = 83677 AND Part_No = ''''116402'''' AND Revision = ''''A'''' ' 
SET @SQL = 'SELECT Plexus_Customer_No, Part_No, Revision, Name, Weight, Part_Status FROM Part_V_Part_E AS P WHERE Plexus_Customer_No = 83677 AND Part_No = ''''116402'''' AND Revision = ''''A'''' ' 

EXEC(@OpenQuery + @SQL + @End_Open_Query)
--EXEC(@OPENQUERY + @SQL_SELECT + @SQL_FROM + @SQL_WHERE + @SQL_ORDER_BY + @End_Open_Query)






