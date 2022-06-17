SELECT
  CGM.Plexus_Customer_Code
  , Add_Date
  , Revision_Key
  , Part_Key
  , Part_No
  , Revision
FROM Part_v_Part_Revision_e AS P
LEFT JOIN Plexus_Control_v_Customer_Group_Member AS CGM
  ON P.PCN = CGM.Plexus_Customer_No
WHERE PCN = 83407
  AND P.Add_Date >= GETDATE() - 8
GROUP BY
  CGM.Plexus_Customer_Code
  , Add_Date
  , Revision_Key
  , Part_Key
  , Part_No
  , Revision
ORDER BY
  CGM.Plexus_Customer_Code
  , Add_Date
  , Revision_Key
  , Part_Key DESC