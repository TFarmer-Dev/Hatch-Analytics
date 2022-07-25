USE [Plex_Facts]
GO

/****** Object:  Table [dbo].[GL_Inventory_Adjustments_f]    Script Date: 7/18/2022 11:05:44 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GL_Inventory_Adjustments_f]') AND type in (N'U'))
DROP TABLE [dbo].GL_Inventory_Adjustments_f
GO

/****** Object:  Table [dbo].[GL_Inventory_Adjustments_f]    Script Date: 7/18/2022 11:05:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].GL_Inventory_Adjustments_f(
	[Id] [int] IDENTITY(1000,1) NOT NULL,
	[Table_Updated_Date] [datetime2](7) NULL,
	[Plexus_Customer_No] [int] NULL,
	[Plexus_Customer_Code] [nvarchar](256) NULL,
	[Account_No] [nvarchar](20) NULL,
	[Description] [nvarchar](500) NULL,
	[Artifical_Date] [datetime2] NULL,
	[Period] [int] NULL,
	[Debit] [float] NULL,
	[Credit] [float] NULL,
	[Net_Abs] [float] NULL
 CONSTRAINT [PK_IvnAdj] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


