USE [Plex_Facts]

DROP TABLE IF EXISTS [Plex_Facts].[Dbo].[Mach2_Scanned_Serials_f]
CREATE TABLE [Plex_Facts].[Dbo].[Mach2_Scanned_Serials_f]
(
  [Id] [int] IDENTITY(1001,1) NOT NULL
, [Table_Updated_Date] [datetime2](7) NULL
, Plexus_Customer_No int
, Plexus_Customer_Code varchar(100)
, Scan_Timestamp datetime2
, Scan_String_Before_Validate varchar(100)
, Scan_String_After_Validate varchar(100)
);