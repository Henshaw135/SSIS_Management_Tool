CREATE PROCEDURE [SSIS].[SP_Control_SSIS]
	(	@SSIS_Package_Name	VARCHAR(50)
		,@ReportGroup		VARCHAR(30)
		,@Frequency		VARCHAR(15)
	)
AS

IF @ReportGroup IS NULL AND @Frequency IS NULL
BEGIN
	SET @ReportGroup = 'All'
	SET @Frequency = 'All'
END

/*--Creates Temp Table for which SSIS Packages to run--*/
DROP TABLE IF EXISTS SSIS.#SSIS_Temp

CREATE TABLE SSIS.#SSIS_Temp (
	Rank_				INT
	,ID_Number			INT
	,SSIS_Package_Name		VARCHAR(50)
	,Report_Group			VARCHAR(30)
	,Frequency			VARCHAR(15)
	,SSIS_Dir			VARCHAR(255)
)


INSERT INTO SSIS.#SSIS_Temp
SELECT	RANK() OVER (ORDER BY ID_Number) AS Rank_, ID_Number ,SSIS_Package_Name, Report_Group, Frequency, SSIS_Dir
FROM	SSIS.Control_SSIS
WHERE	(SSIS_Package_Name IN (@SSIS_Package_Name) OR 'All' = @SSIS_Package_Name)
		AND (Report_Group IN (@ReportGroup) OR 'All' = @ReportGroup)
		AND (Frequency IN (@Frequency) OR 'All' = @Frequency)
		AND IsEnabledYN = 'Yes'

/*--Executing SSIS Procedure with SELECTed SSIS Packages--*/
--Declare String for execution
DECLARE @ssisstr VARCHAR(8000)
	,@ssisPackageDir VARCHAR(200)
	,@ssisPackage VARCHAR(50)
	,@int INT
	--now execute dynamic SQL by using EXEC.  Return Code provides Success of package run.  Details below for numbers.
	,@returncode INT
	,@LogID INT
	,@BatchID INT

SET @int = 1
SET @LogID = (SELECT ISNULL(MAX([LogID]),0) FROM [SSIS].[SSIS_Logs]) + 1
SET @BatchID = (SELECT ISNULL(MAX([BatchID]),0) FROM [SSIS].[SSIS_Logs]) + 1

WHILE @int <= (SELECT max(Rank_) FROM SSIS.#SSIS_Temp)
BEGIN
	SET @ssisPackage = (SELECT SSIS_Package_Name FROM SSIS.#SSIS_Temp WHERE Rank_ = @int)
	SET @ssisPackageDir = (SELECT SSIS_Dir FROM SSIS.#SSIS_Temp WHERE Rank_ = @int)

	/*--Executes the SSIS Packages--*/
	--now making "dtexec" SQL from dynamic values
	SET @ssisstr = 'dtexec /f "' + @ssisPackageDir + '\' + @ssisPackage + '.dtsx" /Reporting N'
	--print line for verification 
	PRINT @ssisstr

	EXEC @returncode = xp_cmdshell @ssisstr

	--Result of Execution
	INSERT INTO SSIS.SSIS_Logs
	SELECT 
		@LogID AS LogID 
		,@BatchID AS BatchID
		,@ssisPackage AS SSIS_Package
		,@returncode AS ReturnCode
		,CASE
			WHEN @returncode = 0 THEN 'The package executed successfully'
			WHEN @returncode = 1 THEN 'The package failed'
			--WHEN @returncode = 2 THEN ''	--Theres no Exit code #2, guess they dont like the only even prime number...
			WHEN @returncode = 3 THEN 'The package was cancelled by the user'
			WHEN @returncode = 4 THEN 'The utility was unable to locate the requested package. The package could not be found'
			WHEN @returncode = 5 THEN 'The utility was unable to load the requested package. The package could not be loaded'
			WHEN @returncode = 6 THEN 'The utility encountered an INTernal error of syntactic or semantic errors in the command line'
		END AS Result
		,CONVERT(DATE,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0)) AS Date_Executed
		,CONVERT(TIME(0),GETDATE()) AS Time_Executed

	SET @int = @int + 1
	SET @LogID = @LogID + 1
	SET @ssisPackage = (SELECT SSIS_Package_Name FROM SSIS.#SSIS_Temp WHERE Rank_ = @int)
END

GO
