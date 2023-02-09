USE [Plex_Facts]

DROP TABLE  [Plex_Facts].[Dbo].[Employee_Movement_f]
CREATE TABLE [Plex_Facts].[Dbo].[Employee_Movement_f]
(
  [Id] [int] IDENTITY(1001,1) NOT NULL
  , [Table_Updated_Date] [datetime2](7) NULL
  , [Plexus_Customer_No] int
  , [Building] varchar(128)
  , [Plexus_User_No] int
  , [Reports_To] varchar(50)  
  , [User_ID] varchar(50)
  , [ADP_File_No] varchar(50)
  , [Last_Name] varchar(100)
  , [First_Name] varchar(100)
  , [Employee_Status] varchar(50)
  , [Contract_Worker] bit
  , [Hire_Date] datetime
  , [Contract_Hire_Date] datetime
  , [Rehire_Date] datetime
  , [Termination_Date] datetime
  , [Department] varchar(50)
  , [Position] varchar(50)
  , [Pay_Type] varchar(50)
  , [Part_Time] bit
  , [Employee_Type] varchar(50)
  , [Temp_Agency] varchar(50)
);