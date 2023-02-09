/* Setup an entire Plex 'replicated' table from start to finish for archiving and storing stored procedures*/
----------------------------- ODBC OPENQUERY View --------------------------------------------
USE [Plex_Accelerated]
GO

/****** Object:  View [dbo].[Stored_Procedure_Information_v]    Script Date: 9/2/2022 2:33:21 PM ******/
DROP VIEW [dbo].[Stored_Procedure_Information_v]
GO

/****** Object:  View [dbo].[Stored_Procedure_Information_v]    Script Date: 9/2/2022 2:33:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Stored_Procedure_Information_v]
AS

SELECT * FROM OPENQUERY(PLEX_VIEWS,
'SELECT S.Pcn, Cgm.Plexus_Customer_Code, S.Created_Date, S.Author_Pun, Author_Last = Pua.Last_Name
, Author_First = Pua.First_Name, S.Last_Altered, S.Last_Altered_Pun, Editor_Last = Pum.Last_Name, Editor_First = Pum.First_Name
, S.Stored_Procedure_Name, S.Specific_Name, S.Stored_Procedure_Key, S.Note, S.Stored_Procedure_Text
FROM Accelerated_Stored_Procedure_Information_E AS S
LEFT JOIN Plexus_Control_V_Customer_Group_Member AS Cgm ON Cgm.Plexus_Customer_No = S.Pcn
LEFT JOIN Plexus_Control_V_Plexus_User_E AS Pua ON Pua.Plexus_Customer_No = S.Pcn AND Pua.Plexus_User_No = S.Author_Pun
LEFT JOIN Plexus_Control_V_Plexus_User_E AS Pum ON Pum.Plexus_Customer_No = S.Pcn AND Pum.Plexus_User_No = S.Last_Altered_Pun
ORDER BY S.Last_Altered DESC')
GO

------------ DROP & CREATE fact table (system-versioned temporal table) --------------------------
USE [Plex_Accelerated]
GO

/****** Object:  Table [dbo].[Stored_Procedure_Information_f]    Script Date: 9/2/2022 1:53:05 PM ******/
ALTER TABLE [dbo].[Stored_Procedure_Information_f] SET ( SYSTEM_VERSIONING = OFF  )
GO

/****** Object:  Table [dbo].[Stored_Procedure_Information_f]    Script Date: 9/2/2022 1:53:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stored_Procedure_Information_f]') AND type in (N'U'))
DROP TABLE [dbo].[Stored_Procedure_Information_f]
GO

/****** Object:  Table [dbo].[Stored_Procedure_Information_h]    Script Date: 9/2/2022 1:53:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stored_Procedure_Information_h]') AND type in (N'U'))
DROP TABLE [dbo].[Stored_Procedure_Information_h]
GO

/****** Object:  Table [dbo].[Stored_Procedure_Information_h]    Script Date: 9/2/2022 1:53:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Stored_Procedure_Information_h](
	[ID] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL,
	[Pcn] [int] NOT NULL,
	[Plexus_Customer_Code] [varchar](256) NULL,
	[Created_Date] [datetime2](7) NULL,
	[Author_Pun] [int] NULL,
	[Author_Last] [varchar](256) NULL,
	[Author_First] [varchar](256) NULL,
	[Last_Altered] [datetime2](7) NULL,
	[Last_Altered_Pun] [int] NULL,
	[Editor_Last] [varchar](256) NULL,
	[Editor_First] [varchar](256) NULL,
	[Stored_Procedure_Name] [varchar](max) NULL,
	[Specific_Name] [varchar](max) NULL,
	[Stored_Procedure_Key] [int] NULL,
	[Note] [varchar](max) NULL,
	[Stored_Procedure_Text] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Stored_Procedure_Information_f]    Script Date: 9/2/2022 1:53:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Stored_Procedure_Information_f](
	[ID] [int] Identity(1001, 1) NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[Pcn] [int] NOT NULL,
	[Plexus_Customer_Code] [varchar](256) NULL,
	[Created_Date] [datetime2](7) NULL,
	[Author_Pun] [int] NULL,
	[Author_Last] [varchar](256) NULL,
	[Author_First] [varchar](256) NULL,
	[Last_Altered] [datetime2](7) NULL,
	[Last_Altered_Pun] [int] NULL,
	[Editor_Last] [varchar](256) NULL,
	[Editor_First] [varchar](256) NULL,
	[Stored_Procedure_Name] [varchar](max) NULL,
	[Specific_Name] [varchar](max) NULL,
	[Stored_Procedure_Key] [int] NULL,
	[Note] [varchar](max) NULL,
	[Stored_Procedure_Text] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dbo].[Stored_Procedure_Information_h] )
)
GO


------------ INSERT data into fact table  (system-versioned temporal table) using the view from above --------------------------
USE [Plex_Accelerated]
GO

INSERT INTO [dbo].[Stored_Procedure_Information_f]
           ([Pcn]
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
           ,[Stored_Procedure_Text])

SELECT
		   [Pcn]
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
		    FROM Plex_Accelerated.Dbo.Stored_Procedure_Information_v AS Sp
			ORDER BY Last_Altered ASC
GO
