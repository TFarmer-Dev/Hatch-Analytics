USE [Plex_Accelerated]
INSERT INTO [dbo].[GL_Account_Activity_Detail_v_e_f]
SELECT 
  Table_Updated_Date = GETDATE()
  , Plexus_Customer_No
  , Plexus_Customer_Code
  , Type
  , Period
  , Date
  , Number
  , Account_No
  , Description
  , Debit
  , Credit
  , Currency_Code
  , Voucher_No
FROM openquery(PLEX_VIEWS, 'SELECT
  Plexus_Customer_No
  , Plexus_Customer_Code
  , Type
  , Period
  , Date
  , Number
  , Account_No
  , Description
  , Debit
  , Credit
  , Currency_Code
  , Voucher_No

																								FROM Plex.Accelerated_GL_Account_Activity_Detail_v_e AS GL
																								--WHERE Plexus_Customer_No IN(83677, 83407, 83678, 83679, 83680, 83682, 83683, 87173) 
																								WHERE Plexus_Customer_No NOT IN(83677, 83407, 83678, 83679, 83680, 83682, 83683, 87173) 
																								AND YEAR(GL.Date) = YEAR(GETDATE()) - 3'
																					)

