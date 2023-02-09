USE [Plex_Facts]

DROP TABLE IF EXISTS [Plex_Facts].[Dbo].[Locations_f]
CREATE TABLE [Plex_Facts].[Dbo].[Locations_f]
(
  [Id] [int] IDENTITY(1001,1) NOT NULL
, [Table_Updated_Date] [datetime2](7) NULL
, Plexus_Customer_No int
, Plexus_Customer_Code varchar(100)
);