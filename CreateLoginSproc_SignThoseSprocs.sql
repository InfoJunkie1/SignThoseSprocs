USE SignThoseSprocs
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE dbo.checksSuccessfulLoginAudit

AS
/******************************************************************************
* Description: brings back information from the last three days of the successful
*     login audit
*			   	
*			
* Procedure Test: 
	
	EXEC dbo.checksSuccessfulLoginAudit

* Change History:
* -----------------------------------------------------------------------------
* Date			|Author				|Reason
* -----------------------------------------------------------------------------
* 04/01/2024	Sharon Reid		Initial Release
*******************************************************************************/
BEGIN

	SET NOCOUNT ON;
	
	--do stuff
	SELECT server_principal_name
		, application_name
		, host_name
		, aa.name AS ActionName
	FROM sys.fn_get_audit_file ('C:\Audits\Successful_Login*.sqlaudit', DEFAULT, DEFAULT) AS a
	LEFT JOIN sys.dm_audit_class_type_map AS cm
		ON a.class_type = cm.class_type
	LEFT JOIN sys.dm_audit_actions AS aa
		ON (aa.action_ID = a.action_ID AND aa.class_desc = cm.securable_class_desc)
	WHERE succeeded = 1
	and event_time >= dateadd(d, -3, getdate())	



END;

