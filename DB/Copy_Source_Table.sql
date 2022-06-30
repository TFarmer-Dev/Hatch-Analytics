-- ================================
-- Copy SOURCE-TABLE
-- ================================
  
-- Drop the Temp table first if it already exists
IF OBJECT_ID(N'tempdb..#TEMP_SOURCE') IS NOT NULL
       BEGIN
              DROP TABLE #TEMP_SOURCE
       END
  
  
-- Insert the linked server table into a temp table
SELECT *
INTO #TEMP_SOURCE
FROM OPENQUERY([PLEX_VIEWS], N'SELECT * FROM Accelerated_Part_v_e')
  
-- If the temp table has rows drop the destination table and recreate the temp table
--IF((SELECT count(*) FROM #TEMP_SOURCE)>0)
BEGIN
       -- We drop in case the schema has changed at the source
       --DROP TABLE IF EXISTS [Plex_Accelerated].[dbo].[Part_f]; 
        
       -- Recreate the destination table schema and data
       SELECT *
       INTO [Plex_Accelerated].[dbo].[Part_v_e_f]
       FROM #TEMP_SOURCE
END
