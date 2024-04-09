--Create audits

USE Master
GO

Create Server Audit Successful_Login
To File
(
	Filepath = N'C:\Audits' --update here to where you want to save your audit files
	, MaxSize = 25MB
	, Max_Rollover_Files = 5
	, Reserve_Disk_Space = OFF
)
WITH
(
	Queue_Delay = 1000
	, On_Failure = Continue
)
GO

ALTER Server Audit Successful_Login
WITH
(
	State = ON
)
GO

Create Server Audit Specification ServerAuditSpec_SuccessfulLogins
For Server Audit Successful_Login
	ADD (Successful_Login_Group),
	ADD (Successful_Database_Authentication_Group)
WITH
(
	State = ON
)
GO