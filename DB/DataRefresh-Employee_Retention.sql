 USE [Plex_Facts];

  DECLARE
  @Hire_Filter_Date varchar(50)

-------------------------------------------
-- These Parameters won't be used in Filtering
-------------------------------------------
DECLARE
  @PCN int
, @Plexus_User_No INT
, @StartDate datetime
, @EndDate datetime
,  @Timezone_Offset int = 0
, @Hire_Date datetime = ''
, @Record_Count int
, @Loop_No int
, @Module_Key int = 36
, -- Employee List
  @Application_Key int = 54
, -- Employee Form
  @Module_Key_2 int = 17
, -- User List
  @Application_Key_2 int = 4383
, -- User Form
  --@Plexus_User_No INT, -- Plexus User No
  @Employee_Status varchar(50) = ''
, @Term_Date datetime = ''
, @Field_To_Parse_Out varchar(50) = 'Status: Inactive'
, -- Employee Rev History Value
  @Field_To_Parse_Out_2 varchar(50) = 'Active: False'
, -- User Rev History Value
  @Rev_Date datetime
, @Yes varchar(50) = 'Yes'
, @No varchar(50) = 'No'
, @Nothing varchar(50) = NULL

  --- Added by TDF ------------------
, @Building varchar(100)
, @EmployeeCountStart int
, @EmployeeCountStartPeriod int
, @EmployeeCountEnd int
, @EmployeeCountEndPeriod int
, @EmployeeCountRegStart int
, @EmployeeCountRegStartPeriod int
, @EmployeeCountRegEnd int
, @EmployeeCountRegEndPeriod int
, @EmployeeCountTempStart int
, @EmployeeCountTempStartPeriod int
, @EmployeeCountTempEnd int
, @EmployeeCountTempEndPeriod int
, @EmployedPeriod int
, @EmployedPeriodReg int
, @EmployedPeriodTemp int
, @NewHired int
, @NewHiredReg int
, @NewHiredTemp int
, @AvgEmployees decimal(15, 2)
, @AvgEmployeesReg decimal(15, 2)
, @AvgEmployeesTemp decimal(15, 2)
, @Terminated int
, @TerminatedReg int
, @TerminatedTemp int
, @TurnOverRate decimal(15, 2)
, @TurnOverRateReg decimal(15, 2)
, @TurnOverRateTemp decimal(15, 2)
, @RetentionRate decimal(15, 2)
, @RetentionRateReg decimal(15, 2)
, @RetentionRateTemp decimal(15, 2)
, @RateNumerator decimal(15, 2)
, @RateNumeratorReg decimal(15, 2)
, @RateNumeratorTemp decimal(15, 2)
, @RateDenominator decimal(15, 2)
, @RateDenominatorReg decimal(15, 2)
, @RateDenominatorTemp decimal(15, 2)
, @TurnOver int
, @TurnOverReg int
, @TurnOverTemp int
, @Retention int
, @RetentionReg int
, @RetentionTemp int
, @Numerator int
, @NumeratorReg int
, @NumeratorTemp int
, @Denominator int
, @DenominatorReg int
, @DenominatorTemp int
, @Measure_Category varchar(50)
, @Year int
, @Goal DECIMAL(19, 2)
, @ChartTypeRate VARCHAR(16)

IF @PCN = '' OR @PCN IS NULL
BEGIN
  --SET @PCN = 83407
  SET @PCN = 83677
END

SET @StartDate = '01-01-2021' 
SET @EndDate = GETDATE()
SET @Goal = 40.0

IF @PCN = '' OR @PCN IS NULL
BEGIN
  --SET @PCN = 83407
  SET @PCN = 83677
END

SET @StartDate = '01-01-2021' 
SET @EndDate = GETDATE()
SET @Goal = 40.0


SET @Building = (SELECT
  CASE @PCN
    WHEN NULL THEN 'All Plants'
    WHEN 22576 THEN 'Hatch-Stamping Company'
    WHEN 83407 THEN 'Hatch-Howell'
    WHEN 83677 THEN 'Hatch-Industrial Drive'
    WHEN 83678 THEN 'Hatch-Cleveland Stamping'
    WHEN 83679 THEN 'Hatch-Cleveland Die Shop'
    WHEN 83680 THEN 'Hatch-Fowlerville Assy'
    WHEN 83682 THEN 'Hatch-Mexico'
    WHEN 83683 THEN 'Hatch-Corp Office'
    WHEN 87173 THEN 'Hatch-Spring Arbor Coatings LLC'
    WHEN 127713 THEN 'Hatch Stamping Warehouse'
    WHEN 265864 THEN 'Hatch-MEXPAINT'
    WHEN 270929 THEN 'Hatch-SAC Fowlerville'
    WHEN 281389 THEN 'Hatch-Mexico Peso'
    WHEN 281993 THEN 'Hatch-Jay Bird Drive'
    WHEN 288744 THEN 'Hatch-Distibution'
    WHEN 289762 THEN 'Old-Hatch-Distribution'
    WHEN 289910 THEN 'Hatch-Vaughn Parkway'
    WHEN 292534 THEN 'Hatch Chattanooga'
    WHEN 297704 THEN 'Hatch Changshu'
  END AS 'Building')

----------------------------------
-------------------------------------------
-- Create Tables
-------------------------------------------
DROP TABLE IF EXISTS #Employee_Data_Raw;
/*
CREATE TABLE #Employee_Data_Raw (
  Plexus_User_No int
, Reports_To varchar(50)  
, User_ID varchar(50)
, ADP_File_No varchar(50)
, Last_Name VARCHAR(100)
, Employee_Status varchar(50)
, Contract_Worker bit
, Hire_Date datetime
, Contract_Hire_Date datetime
, Termination_Date datetime
, Building varchar(50)
, Department varchar(50)
, Position varchar(50)
, Pay_Type varchar(50)
, Part_Time bit
, Employee_Type varchar(50)
, Temp_Agency varchar(50)
)
*/

DROP TABLE IF EXISTS #Employee_Data_Clean;
CREATE TABLE #Employee_Data_Clean (
  Plexus_User_No int
, Reports_To varchar(50)    
, User_ID varchar(50)
, ADP_File_No varchar(50)
, Last_Name VARCHAR(100)
, First_Name VARCHAR(100)
, Employee_Status varchar(50)
, Contract_Worker bit
, Hire_Date datetime
, Contract_Hire_Date datetime
, Termination_Date datetime
, Building varchar(50)
, Department varchar(50)
, Position varchar(50)
, Pay_Type varchar(50)
, Part_Time bit
, Employee_Type varchar(50)
, Temp_Agency varchar(50)
)

DROP TABLE IF EXISTS #Final_Result_Start;
CREATE TABLE #Final_Result_Start (
  ID varchar(50)
, Year int
, Plexus_User_No int
, Reports_To varchar(50)  
, User_ID varchar(50)
, ADP_File_No varchar(50)
, Last_Name VARCHAR(100)
, First_Name VARCHAR(100)
, Employee_Status varchar(50)
, Contract_Worker varchar(50)
, Hire_Date datetime
, Contract_Hire_Date datetime
, Termination_Date datetime
, Building varchar(50)
, Department varchar(50)
, Position varchar(50)
, Pay_Type varchar(50)
, Part_Time varchar(50)
, Employee_Type varchar(50)
, Temp_Agency varchar(50)
)

DROP TABLE IF EXISTS #Final_Result_End
CREATE TABLE #Final_Result_End (
  ID varchar(50)
, Year int
, Plexus_User_No int
, Reports_To varchar(50)  
, User_ID varchar(50)
, ADP_File_No varchar(50)
, Last_Name VARCHAR(100)
, First_Name VARCHAR(100)
, Employee_Status varchar(50)
, Contract_Worker varchar(50)
, Hire_Date datetime
, Contract_Hire_Date datetime
, Termination_Date datetime
, Building varchar(50)
, Department varchar(50)
, Position varchar(50)
, Pay_Type varchar(50)
, Part_Time varchar(50)
, Employee_Type varchar(50)
, Temp_Agency varchar(50)
)

DROP TABLE IF EXISTS #Measures
CREATE TABLE #Measures (
  Measure_Category varchar(100)
, Measure varchar(100)
, CountValue int
, RateValue decimal(15, 2)
, Suffix varchar(5)
, YearValue nvarchar(100)
)

-------------------------------------------
-- Steps
-------------------------------------------
SET @Year = 2016
-- Step 1: Handle Timezone Offset and Set End Date to Next Day
--SET @Timezone_Offset = (SELECT TOP (1) Z.Timezone_Offset FROM Plexus_Control_v_Customer_Group_Member AS C JOIN Plexus_Control_v_Logical_Timezone AS Z ON C.Timezone_Key = Z.Timezone_Key WHERE C.Plexus_Customer_No = @PCN) * -60

-- Step 2: Get Employee Data
SELECT TOP 500 * INTO #Employee_Data_Raw FROM [Plex_Facts].[Dbo].[Employee_Movement_f] AS PU ORDER BY PU.Plexus_User_No
/*
SELECT
  PU.Plexus_User_No
  , E.Reports_To  
  , PU.User_ID
  , E.Customer_Employee_No
  , PU.Last_Name + ', ' + PU.First_Name AS 'Employee'
  , E.Employee_Status
  , E.Contract_Worker
  , CASE
      WHEN EA.Contract_Hire_Date IS NOT NULL AND
        EA.Contract_Hire_Date >= E.Hire_Date THEN NULL
      ELSE E.Hire_Date
    END AS 'Hire_Date'
  , EA.Contract_Hire_Date
  , CASE
      WHEN E.Employee_Status != 'Inactive' THEN NULL
      WHEN EA.Contract_Hire_Date IS NOT NULL AND
        EA.Contract_Hire_Date >= E.Hire_Date THEN NULL
      ELSE OAT.Term_Date
    END AS 'Term_Date'
  , isnull(B.Building_Code, 'Undefined')
  , D.Department_Code
  , P.Position
  , CASE
      WHEN E.Pay_Type = '' THEN 'Undefined'
      ELSE E.Pay_Type
    END AS 'Pay_Type'
  , EA.Eligible_For_Salary
  , CASE
      WHEN S.Supplier_Code IS NOT NULL THEN 'Temporary'
      ELSE ET.Employee_Type
    END AS Employee_Type
  , S.Supplier_Code

FROM Personnel_v_Employee AS E

  JOIN Plexus_Control_v_Plexus_User AS PU
    ON PU.Plexus_Customer_No = @PCN
    AND PU.Plexus_User_No = E.Plexus_User_No

  RIGHT JOIN Common_v_Position AS P
    ON P.Plexus_Customer_No = @PCN
    AND P.Position_Key = PU.Position_Key

  LEFT JOIN Personnel_v_Employee_Type AS ET
    ON ET.PCN = @PCN
    AND ET.Employee_Type_Key = E.Employee_Type_Key

  LEFT JOIN Personnel_v_Employee_Attributes AS EA
    ON EA.PCN = @PCN
    AND EA.Plexus_User_No = PU.Plexus_User_No

  LEFT JOIN Common_v_Department AS D
    ON D.Plexus_Customer_No = @PCN
    AND D.Department_No = PU.Department_No

  LEFT JOIN Common_v_Building AS B
    ON B.Plexus_Customer_No = @PCN
    AND B.Building_Key = PU.Building_Key

  LEFT JOIN Common_v_Supplier AS S
    ON S.Plexus_Customer_No = @PCN
    AND S.Supplier_No = E.Supplier_Key

OUTER APPLY (SELECT TOP (1)
    T.Plexus_User_No
  , T.Termination_Date AS 'Term_Date'

FROM Personnel_v_Termination AS T

WHERE T.PCN = @PCN
  AND T.Plexus_User_No = PU.Plexus_User_No
  AND T.Termination_Date IS NOT NULL
  AND T.Termination_Date >= E.Hire_Date

ORDER BY T.Termination_Date DESC) OAT

WHERE (
  E.Plexus_Customer_No = @PCN
  AND P.Position != 'System Resource' -- Test Accounts
  AND E.Hire_Date IS NOT NULL
  AND E.Contract_Worker = 0
  )
  OR (
  E.Plexus_Customer_No = @PCN
  AND P.Position != 'System Resource' -- Test Accounts
  AND EA.Contract_Hire_Date IS NOT NULL
  AND E.Contract_Worker = 1
  )

ORDER BY PU.Plexus_User_No
*/
-- Step 3: Loops through Employees and Insert Terminations Dates where NULL with Inactive Status Rev History Date
SET @Record_Count = (SELECT
  count(Plexus_User_No)
FROM #Employee_Data_Raw AS edr)
SET @Loop_No = 1
SET @Plexus_User_No = 0


IF (@Record_Count > 0)
BEGIN
  WHILE (@Loop_No <= @Record_Count)
  BEGIN
    SET @Plexus_User_No = (SELECT TOP (1)
      Plexus_User_No
    FROM #Employee_Data_Raw AS edr
    WHERE Plexus_User_No > @Plexus_User_No
    ORDER BY Plexus_User_No ASC)
    SET @Employee_Status = (SELECT TOP (1)
      Employee_Status
    FROM #Employee_Data_Raw AS edr
    WHERE Plexus_User_No = @Plexus_User_No)
    SET @Term_Date = (SELECT TOP (1)
      Termination_Date
    FROM #Employee_Data_Raw AS edr
    WHERE Plexus_User_No = @Plexus_User_No)

    -- Insert inactive Employees Missing Termination Records
    -- 1st Attempt to get the Date from the Employee Rev History
    IF (@Employee_Status != 'Active'
      AND @Term_Date IS NULL)
    BEGIN

      -- Last Attempt to get the Date from the User Last Update Date
      -- Account was never used if this doesn't work, so don't insert them into the table
      IF (@Term_Date IS NULL)
      BEGIN

        SET @Term_Date = (SELECT TOP (1)
          U.Termination_Date

        FROM [Plex_Facts].[Dbo].[Employee_Movement_f] AS U

        WHERE U.Plexus_Customer_No = @PCN
        AND U.Plexus_User_No = @Plexus_User_No

        ORDER BY U.Termination_Date DESC)
      END

      IF (@Term_Date IS NOT NULL)
      BEGIN

        INSERT #Employee_Data_Clean

          SELECT
            E.Plexus_User_No
          , E.Reports_To  
          , E.User_ID
          , E.ADP_File_No
          , E.Last_Name
		  , E.First_Name
          , E.Employee_Status
          , E.Contract_Worker
          , E.Hire_Date
          , E.Contract_Hire_Date
          , @Term_Date
          , E.Building
          , E.Department
          , E.Position
          , E.Pay_Type
          , E.Part_Time
          , E.Employee_Type
          , E.Temp_Agency

          FROM #Employee_Data_Raw AS E

          WHERE E.Plexus_User_No = @Plexus_User_No

      END
    END
    ELSE
    BEGIN

      INSERT #Employee_Data_Clean

        SELECT
          E.Plexus_User_No
        , E.Reports_To  
        , E.User_ID
        , E.ADP_File_No
        , E.Last_Name
		, E.First_Name
        , E.Employee_Status
        , E.Contract_Worker
        , E.Hire_Date
        , E.Contract_Hire_Date
        , E.Termination_Date
        , E.Building
        , E.Department
        , E.Position
        , E.Pay_Type
        , E.Part_Time
        , E.Employee_Type
        , E.Temp_Agency

        FROM #Employee_Data_Raw AS E

        WHERE E.Plexus_User_No = @Plexus_User_No
    END

    SET @Loop_No = @Loop_No + 1
  END
END



WHILE @Year <= cast(datepart(yy, getdate()) AS int)
BEGIN
  -- Step 4a: For the start of the period, INSERT active employees into the #Final_Result
  SET @StartDate = dateadd(YEAR, 0, CONCAT(@Year, '/1/1'))
  SET @Hire_Filter_Date = @StartDate
  SET @Hire_Date = convert(datetime, @Hire_Filter_Date)
  --SET @Hire_Date = SWITCHOFFSET(@Hire_Date, @Timezone_Offset)
  --SET @Hire_Date = @Hire_Date + 1 -- End of Day
  --SELECT @Hire_Date

  -- Employees with Hire Date < Filtered Hire Date and NULL Contract Hire Date (Consider Full Time)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Hire_Date < @Hire_Date
    AND E.Contract_Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and NULL Hire Date (Consider Temp)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and Hire Date > Filtered Hire Date (Consider Temp)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date >= @Hire_Date -- Remember @Hire_Date is Next Day

  -- Employees with Contract Hire Date and Hire Date < Filtered Hire Date (Consider Full Time)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date < @Hire_Date

  -- Step 5a: Insert Inactive Employee into Final Result with addition of Term Date logic

  -- Employees with Hire Date < Filtered Hire Date and NULL Contract Hire Date (Consider Full Time)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , @Nothing

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Hire_Date  -- Handles where Employees were Terminated before starting
    AND E.Hire_Date < @Hire_Date
    AND E.Contract_Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and NULL Hire Date (Consider Temp)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Contract_Hire_Date -- Handles where Employees were Terminated before starting
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and Hire Date > Filtered Hire Date (Consider Temp)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency -- Might need future logic to lookup from history if needed.

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Contract_Hire_Date -- Handles where Employees were Terminated before starting
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date >= @Hire_Date -- Remember @Hire_Date is Next Day

  -- Employees with Contract Hire Date and Hire Date < Filtered Hire Date (Consider Full Time)
  INSERT #Final_Result_Start

    SELECT
      'Starting ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , @Nothing

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Hire_Date -- Handles where Employees were Terminated before starting
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date < @Hire_Date

 SET @Measure_Category = 'All'
  SET @EmployeeCountStart =
  (
    SELECT
      count(Plexus_User_No)
    FROM #Final_Result_Start AS Final
    WHERE ID LIKE ('Starting ' + convert(varchar(15), @Year))
  )

  IF @Year = year(@StartDate)
    SET @EmployeeCountStartPeriod =
    (
      SELECT
        count(Plexus_User_No)
      FROM #Final_Result_Start AS starting
      WHERE Year >= year(@StartDate)
    )

 SET @Measure_Category = 'Regular'
  SET @EmployeeCountRegStart =
  (
    SELECT
      count(Plexus_User_No)
    FROM #Final_Result_Start AS Final
    WHERE ID LIKE ('Starting ' + convert(varchar(15), @Year))
    AND Employee_Type != @Measure_Category
  )

  IF @Year = year(@StartDate)
    SET @EmployeeCountRegStartPeriod =
    (
      SELECT
        count(Plexus_User_No)
      FROM #Final_Result_Start AS starting
      WHERE Year >= year(@StartDate)
      AND Employee_Type != @Measure_Category
    )
  
  SET @Measure_Category = 'Temporary'
  SET @EmployeeCountTempStart =
  (
    SELECT
      count(Plexus_User_No)
    FROM #Final_Result_Start AS Final
    WHERE ID LIKE ('Starting ' + convert(varchar(15), @Year))
    AND Employee_Type = @Measure_Category
  )

  IF @Year = year(@StartDate)
    SET @EmployeeCountTempStartPeriod =
    (
      SELECT
        count(Plexus_User_No)
      FROM #Final_Result_Start AS starting
      WHERE Year >= year(@StartDate)
      AND Employee_Type = @Measure_Category
    )

  -- Step 4b: For the end of the period, INSERT active employees into the #Final_Result
  SET @EndDate = dateadd(YEAR, 0, CONCAT(@Year, '/12/31'))
  SET @Hire_Filter_Date = @EndDate
  SET @Hire_Date = convert(datetime, @Hire_Filter_Date)

  -- Employees with Hire Date < Filtered Hire Date and NULL Contract Hire Date (Consider Full Time)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Hire_Date < @Hire_Date
    AND E.Contract_Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and NULL Hire Date (Consider Temp)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and Hire Date > Filtered Hire Date (Consider Temp)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date >= @Hire_Date -- Remember @Hire_Date is Next Day

  -- Employees with Contract Hire Date and Hire Date < Filtered Hire Date (Consider Full Time)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status = 'Active'
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date < @Hire_Date

  -- ', NULL,b: Insert Inactive Employee into Final Result with addition of Term Date logic

  -- Employees with Hire Date < Filtered Hire Date and NULL Contract Hire Date (Consider Full Time)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , @Nothing

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Hire_Date  -- Handles where Employees were Terminated before starting
    AND E.Hire_Date < @Hire_Date
    AND E.Contract_Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and NULL Hire Date (Consider Temp)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Contract_Hire_Date -- Handles where Employees were Terminated before starting
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date IS NULL

  -- Employees with Contract Hire Date < Filtered Hire Date and Hire Date > Filtered Hire Date (Consider Temp)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @Yes
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    , E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , E.Temp_Agency -- Might need future logic to lookup from history if needed.

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Contract_Hire_Date -- Handles where Employees were Terminated before starting
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date >= @Hire_Date -- Remember @Hire_Date is Next Day

  -- Employees with Contract Hire Date and Hire Date < Filtered Hire Date (Consider Full Time)
  INSERT #Final_Result_End

    SELECT
      'Ending ' + convert(varchar(15), @Year)
    , @Year
    , E.Plexus_User_No
    , E.Reports_To
    , E.User_ID
    , E.ADP_File_No
    , E.Last_Name
	, E.First_Name
    , E.Employee_Status
    , @No
    , E.Hire_Date
    , E.Contract_Hire_Date
    , E.Termination_Date
    ,
      -- @Building
      E.Building
    , E.Department
    , E.Position
    , E.Pay_Type
    , CASE
        WHEN E.Part_Time = 'False' THEN @No
        ELSE @Yes
      END
    , E.Employee_Type
    , @Nothing

    FROM #Employee_Data_Clean AS E

    WHERE E.Employee_Status != 'Active'
    AND E.Termination_Date >= @Hire_Date
    AND E.Termination_Date > E.Hire_Date -- Handles where Employees were Terminated before starting
    AND E.Contract_Hire_Date < @Hire_Date
    AND E.Hire_Date < @Hire_Date

  -------------------------------------------
  -- Final Result
  -------------------------------------------
  --SELECT TOP 10 * FROM #Employee_Data_Raw AS raw
  --SELECT TOP 500 * FROM #Employee_Data_Clean AS clean ORDER BY Termination_Date DESC
  --SELECT COUNT(Employee_Type) FROM #Final_Result_End AS final WHERE Employee_Type = @Measure_Category

-- TODO: Include a linear Tempression value for counts with percentages. It
--       may not be possible with VisionPlex.

-- SET data for all hourly employees
  SET @Measure_Category = 'ALL'
  
  IF @Year = year(@EndDate)
  BEGIN
    SET @EmployeeCountEndPeriod = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS ending WHERE Year >= year(@StartDate) AND Year <= year(@EndDate))
  END

  SET @EmployeeCountEnd = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS final WHERE ID LIKE ('Ending ' + convert(varchar(15), @Year)))
  SET @Terminated = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS term WHERE year(term.Termination_Date) = @Year)
  SET @NewHired = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS final WHERE year(Hire_Date) = @Year AND year(Hire_Date) IS NOT NULL)
  SET @AvgEmployees = (@EmployeeCountStart + @EmployeeCountEnd) / 2
  SET @EmployedPeriod = (@EmployeeCountEnd - @EmployeeCountStart)
  SET @Denominator = (@EmployeeCountStart + @EmployeeCountEnd) / 2
  SET @Numerator = (@EmployeeCountStart + @EmployeeCountEnd) - @Terminated
  SET @RateDenominator = (@EmployeeCountStart + @EmployeeCountEnd) / 2
  SET @Retention = (@EmployeeCountEnd - @NewHired)
  SET @RetentionRate = (@EmployeeCountEnd - @NewHired) * 100
  SET @TurnOver = (@Terminated / @Denominator)
  SET @TurnOverRate = (@Terminated / @RateDenominator) * 100
  
  -- INSERT data for regular hourly employees
  -- #Measures (Measure_Category varchar(100), Measure varchar(100), CountValue int, RateValue decimal(15, 2), Suffix varchar(5), YearValue nvarchar(100))
  INSERT INTO #Measures VALUES(@Measure_Category, 'Goal', NULL, @Goal, '%', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, @Building, NULL, @TurnOverRate, '%', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'All Hourly Employee Count at the Beginning of Period', @EmployeeCountStart, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'All Hourly Employee Count at the End of Period', @EmployeeCountEnd, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'All Hourly Termination Count for Period', (-1 * @Terminated), NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'All Hourly Hired Count for Period', @NewHired, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'All Hourly Retained Count for Period', @Retention, NULL, '', @Year)  
  
    -- SET data for regular hourly employees
  SET @Measure_Category = 'Regular'
  
  IF @Year = year(@EndDate)
  BEGIN
    SET @EmployeeCountRegEndPeriod = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS ending WHERE Year >= year(@StartDate) AND Year <= year(@EndDate) AND Employee_Type != 'Temporary')
  END    

  SET @EmployeeCountRegEnd = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS final WHERE ID LIKE ('Ending ' + convert(varchar(15), @Year)) AND Employee_Type != 'Temporary')
  SET @TerminatedReg = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS term WHERE year(term.Termination_Date) = @Year AND Employee_Type != 'Temporary') 
  SET @NewHiredReg = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS final WHERE year(Hire_Date) = @Year AND year(Hire_Date) IS NOT NULL AND Employee_Type != 'Temporary')
  SET @AvgEmployeesReg = (@EmployeeCountRegStart + @EmployeeCountRegEnd) / 2
  SET @EmployedPeriodReg = (@EmployeeCountRegEnd - @EmployeeCountRegStart)
  SET @DenominatorReg = (@EmployeeCountRegStart + @EmployeeCountRegEnd) / 2
  SET @NumeratorReg = (@EmployeeCountRegStart + @EmployeeCountRegEnd) - @TerminatedReg
  SET @RateDenominatorReg = (@EmployeeCountRegStart + @EmployeeCountRegEnd) / 2
  SET @RetentionReg = (@EmployeeCountRegEnd - @NewHiredReg)
  SET @RetentionRateReg = (@EmployeeCountRegEnd - @NewHiredReg) * 100  
  SET @TurnOverReg = (@TerminatedReg / @DenominatorReg)
  --SET @TurnOverRateReg = (@TerminatedReg / @RateDenominatorReg) * 100

  -- INSERT data for regular hourly employees
  -- #Measures (Measure_Category varchar(100), Measure varchar(100), CountValue int, RateValue decimal(15, 2), Suffix varchar(5), YearValue nvarchar(100))
  INSERT INTO #Measures VALUES(@Measure_Category, 'Reg. Employee Count at the Beginning of Period', @EmployeeCountRegStart, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Reg. Employee Count at the End of Period', @EmployeeCountRegEnd, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Reg. Termination Count for Period', (-1 * @TerminatedReg), NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Reg. Hired Count for Period', @NewHiredReg, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Reg. Retained Count for Period', @RetentionReg, NULL, '', @Year)

  -- SET data for agency-provided temporary employees
  SET @Measure_Category = 'Temporary'  
  IF @Year = year(@EndDate)
  BEGIN
    SET @EmployeeCountTempEndPeriod = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS ending WHERE Employee_Type = 'Temporary')
  END

  SET @EmployeeCountTempEnd = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS final WHERE  Employee_Type = 'Temporary')
  SET @TerminatedTemp = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS term WHERE Employee_Type = 'Temporary')
  SET @NewHiredTemp = (SELECT DISTINCT count(Plexus_User_No) FROM #Final_Result_End AS final WHERE Employee_Type = 'Temporary')
  SET @AvgEmployeesTemp = (@EmployeeCountTempStart + @EmployeeCountTempEnd) / 2
  SET @EmployedPeriodTemp = (@EmployeeCountTempEnd - @EmployeeCountTempStart)
  SET @DenominatorTemp = (@EmployeeCountTempStart + @EmployeeCountTempEnd) / 2
  SET @NumeratorTemp = (@EmployeeCountTempStart + @EmployeeCountTempEnd) - @TerminatedTemp
  SET @RateDenominatorTemp = (@EmployeeCountTempStart + @EmployeeCountTempEnd) / 2
  SET @RetentionTemp = (@EmployeeCountTempEnd - @NewHiredTemp)
  SET @RetentionRateTemp = (@EmployeeCountTempEnd - @NewHiredTemp) * 100  
  --SET @TurnOverTemp = (@TerminatedTemp / @DenominatorTemp)
  --SET @TurnOverRateTemp = (@TerminatedTemp / @RateDenominatorTemp) * 100

  -- INSERT data for agency-provided temporary employees
  -- #Measures (Measure_Category varchar(100), Measure varchar(100), CountValue int, RateValue decimal(15, 2), Suffix varchar(5), YearValue nvarchar(100))
  INSERT INTO #Measures VALUES(@Measure_Category, 'Temp. Employee Count at the Beginning of Period', @EmployeeCountTempStart, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Temp. Employee Count at the End of Period', @EmployeeCountTempEnd, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Temp. Termination Count for Period', (-1 * @TerminatedTemp), NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Temp. Hired Count for Period', @NewHiredTemp, NULL, '', @Year)
  INSERT INTO #Measures VALUES(@Measure_Category, 'Temp. Retained Count for Period', @RetentionTemp, NULL, '', @Year)

  SET @Year = @Year + 1
END

-- Hatch procedure-generated values
INSERT INTO #Measures VALUES(@Measure_Category, @Building, NULL, @TurnOverRate, '%', @Year)

-- Hatch static-generated values
INSERT INTO #Measures VALUES(@Measure_Category, 'All Plants', NULL, 0, '%', '2016')
INSERT INTO #Measures VALUES(@Measure_Category, 'All Plants', NULL, 17.6, '%', '2017')
INSERT INTO #Measures VALUES(@Measure_Category, 'All Plants', NULL, 24.5, '%', '2018')
INSERT INTO #Measures VALUES(@Measure_Category, 'All Plants', NULL, 32.77, '%', '2019')
INSERT INTO #Measures VALUES(@Measure_Category, 'All Plants', NULL, 43.9, '%', '2020')
INSERT INTO #Measures VALUES(@Measure_Category, 'All Plants', NULL, 49.11, '%', '2021')

-- US Department of Labor and Statistics published rates
SET @Measure_Category = 'US Bureau of Labor and Statistics'
INSERT INTO #Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 25.7, '%', '2016')
INSERT INTO #Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 27.3, '%', '2017')
INSERT INTO #Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 28.8, '%', '2018')
INSERT INTO #Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 28.6, '%', '2019')
INSERT INTO #Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 41.8, '%', '2020')
INSERT INTO #Measures VALUES(@Measure_Category, 'US - Manufacturing Durable Goods', NULL, 35.3, '%', '2021')

INSERT INTO #Measures VALUES(@Measure_Category, 'US Midwest', NULL, 43.2, '%', '2016')
INSERT INTO #Measures VALUES(@Measure_Category, 'US Midwest', NULL, 42.8, '%', '2017')
INSERT INTO #Measures VALUES(@Measure_Category, 'US Midwest', NULL, 45.0, '%', '2018')
INSERT INTO #Measures VALUES(@Measure_Category, 'US Midwest', NULL, 44.0, '%', '2019')
INSERT INTO #Measures VALUES(@Measure_Category, 'US Midwest', NULL, 58.8, '%', '2020')
INSERT INTO #Measures VALUES(@Measure_Category, 'US Midwest', NULL, 47.7, '%', '2021')

-- Reference: https://www.bls.gov/news.release/jolts.t16.htm

  SELECT
    *
  FROM #Measures AS Churn
  --WHERE Suffix = ''
  ORDER BY Measure, YearValue

-------------------------------------------
-- Drop Tables
-------------------------------------------
DROP TABLE #Employee_Data_Raw
DROP TABLE #Employee_Data_Clean
DROP TABLE #Final_Result_Start
DROP TABLE #Final_Result_End
DROP TABLE #Measures