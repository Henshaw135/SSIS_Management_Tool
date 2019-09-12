CREATE TABLE [SSIS].[SSIS_Logs]
(
	LogID			INT		NOT NULL
	,BatchID		INT		NOT NULL
	,SSIS_Package		VARCHAR(50)	NOT NULL
	,ReturnCode		VARCHAR(50)	NOT NULL
	,Result			VARCHAR(150)	NOT NULL
	,Date_Executed		DATE		NOT NULL
	,Time_Executed		TIME(0)		NOT NULL
)