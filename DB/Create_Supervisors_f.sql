USE [Plex_Facts]

DROP TABLE  [Plex_Facts].[Dbo].[Supervisors_f]
CREATE TABLE [Plex_Facts].[Dbo].[Supervisors_f]
(
  [Id] [int] IDENTITY(1001,1) NOT NULL
, [Table_Updated_Date] [datetime2](7) NULL
, Plexus_Customer_No int
, SUP_PUN int
, SUP_Last_Name varchar(100)
, SUP_First_Name varchar(100)
, EMP_PUN int
);