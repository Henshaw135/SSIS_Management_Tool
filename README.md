# SSIS_Management_Tool
SSIS Management tool that executes SSIS Packages from a control table and records logs.  Useful for running multiple SSIS packages.

Important: 
  The SQL Server requires this permission to allow the xp_CMDShell to execute for this tool to work
  All SSIS Packages the pull from folders, the server will need permissions to those folders

This SSIS Management Tool runs SSIS Packages that are stored in the control table.  Typically I create a excel file and load the table in so the excel file is the only place needed to update to add new SSIS packages to the list.

The way this tool has the data flow through is:
Control_SSIS --> SP_Control_SSIS --> SSIS_Logs

To run SP_Control_SSIS:
Running the Stored Procedure can use 'ALL' or a specific package/category and has the structure of:
EXEC SSIS.SP_Control_SSIS 'SSIS Name', 'Report Group', 'Frequency'

Examples:
  To Run Daily (If there is daily in frequency of the control table)
  
   EXEC SSIS.SP_Control_SSIS 'All','All','Daily'
   
  To Run Specific Package
  
   EXEC SSIS.SP_Control_SSIS 'Report_Package','All','All'
   
Project Parts:

Control_SSIS - Table used as resource of all SSIS packages the stored procedure calls

SP_Control_SSIS - Where all the magic happens.  This stored procedure runs all of the SSIS Packages and stores results in the logs table

SSIS_Logs - Log Table to store results of executed stored procedures

SSIS - Creates Schema, nice to have the SSIS packages in its own area of the database
