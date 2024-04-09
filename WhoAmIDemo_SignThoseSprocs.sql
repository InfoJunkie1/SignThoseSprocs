Use SignThoseSprocs 
GO

EXEC dbo.whoAmIReally --under my own context as sysadmin

use [SignThoseSprocs]
GO
GRANT EXECUTE ON [dbo].[whoAmIReally] TO [PamFromTheOffice]
GO

Execute AS USER = 'PamFromTheOffice'
EXEC dbo.whoAmIReally
REVERT

--change impersonation
Execute AS USER = 'PamFromTheOffice'
EXEC dbo.whoAmIReally
REVERT

--now change impersonation again
Execute AS USER = 'PamFromTheOffice'
EXEC dbo.whoAmIReally
REVERT
