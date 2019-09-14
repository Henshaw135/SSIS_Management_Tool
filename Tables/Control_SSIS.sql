CREATE TABLE [SSIS].[Control_SSIS]
(
	ID_Number			INT			NOT NULL	IDENTITY(1,1),
	SSIS_Package_Name		VARCHAR(40)		NOT NULL,
	Report_Group			VARCHAR(30)		NOT NULL,
	Frequency			VARCHAR(15)		NOT NULL,
	SSIS_Dir			VARCHAR(256)		NOT NULL,
	IsEnabledYN			VARCHAR(3)		NOT NULL
)