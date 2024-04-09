--Execute our sproc bringing back audit info 
Use SignThoseSprocs 
GO

EXEC dbo.checksSuccessfulLoginAudit --runs with login with sysadmin

--grant PamFromTheOffice execute on our sproc
use [SignThoseSprocs]
GO
GRANT EXECUTE ON [dbo].[checksSuccessfulLoginAudit] TO [PamFromTheOffice]
GO

--Execute our sproc using PamFromTheOffice context
Use SignThoseSprocs 
GO

Execute as login =  'PamFromTheOffice'
EXEC dbo.checksSuccessfulLoginAudit
REVERT

/*
Now we're going to use Module Signing to extend the permissions :)

Ensure/create database master keys in Master
*/
USE Master 
GO

SELECT * FROM sys.symmetric_keys
WHERE name LIKE '%databasemaster%'

--USE Master
--CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterDatabaseKeyPassword' --use real password and add to password manager

/*
Create a cert in database and secure it with a password
*/
USE SignThoseSprocs 
GO

CREATE CERTIFICATE AuditCert
	ENCRYPTION BY PASSWORD = 'yourUniquePassword' --create/use password and put in password manager
	WITH SUBJECT = 'Certificate to access audit files'

/*
Sign sproc with cert
*/
USE SignThoseSprocs
GO

ADD SIGNATURE TO dbo.checksSuccessfulLoginAudit
BY CERTIFICATE AuditCert
WITH PASSWORD = 'yourUniquePassword'
GO

/*
Copy certificate to Master
https://www.sommarskog.se/grantperm.html#serverlevel
*/

USE SignThoseSprocs 
GO

DECLARE @public_key varbinary(MAX) = 
	certencoded(cert_id('AuditCert')),
	@sql nvarchar(MAX) 

SELECT @sql = 
	'CREATE CERTIFICATE AuditCert
	FROM BINARY = ' + convert(varchar(MAX), @public_key, 1)

USE Master 

PRINT @sql
EXEC(@sql)

/*
Sanity check--check the thumbprints
*/

SELECT name, thumbprint
FROM master.sys.certificates
WHERE name = 'AuditCert'

UNION ALL

SELECT name, thumbprint
FROM SignThoseSprocs.sys.certificates
WHERE name = 'AuditCert'

/*
Create login for cert
*/

USE Master 
GO

CREATE LOGIN AuditCertLogin FROM CERTIFICATE AuditCert
GO

/*
Grant permisssions to login
*/

GRANT CONTROL SERVER TO AuditCertLogin

/*
Verification--ensure sproc signed
*/

USE SignThoseSprocs
GO

SELECT SCHEMA_NAME (so.SCHEMA_ID) AS SchemaName
	, so.name AS ObjectName
	, so.type_desc AS ObjectType
	, scp.crypt_type_desc AS SignatureType
	, COALESCE (sc.name, sak.name) AS CertOrAsymKeyName
	, scp.thumbprint
FROM sys.crypt_properties AS scp
JOIN sys.objects AS so
	ON so.object_id = scp.major_id
LEFT JOIN sys.certificates AS sc
	ON sc.thumbprint = scp.thumbprint
LEFT JOIN sys.asymmetric_keys AS sak
	ON sak.thumbprint = scp.thumbprint
WHERE so.type <> 'U'
ORDER BY SchemaName, ObjectType, ObjectName, CertOrAsymKeyName

/*
Now we're going to try having PamFromTheOffice run that sproc again
*/

Use SignThoseSprocs 
GO

Execute as login =  'PamFromTheOffice'
EXEC dbo.checksSuccessfulLoginAudit
REVERT

/*
What happens if we make a change on our sproc?
*/
Use SignThoseSprocs 
GO

Execute as login =  'PamFromTheOffice'
EXEC dbo.checksSuccessfulLoginAudit
REVERT

/*
After updates, we need to resign the sproc--you will need that password
*/

USE SignThoseSprocs
GO

ADD SIGNATURE TO dbo.checksSuccessfulLoginAudit
BY CERTIFICATE AuditCert
WITH PASSWORD = 'yourUniquePassword'
GO

/*
Verify sproc signed again
*/

USE SignThoseSprocs
GO

SELECT SCHEMA_NAME (so.SCHEMA_ID) AS SchemaName
	, so.name AS ObjectName
	, so.type_desc AS ObjectType
	, scp.crypt_type_desc AS SignatureType
	, COALESCE (sc.name, sak.name) AS CertOrAsymKeyName
	, scp.thumbprint
FROM sys.crypt_properties AS scp
JOIN sys.objects AS so
	ON so.object_id = scp.major_id
LEFT JOIN sys.certificates AS sc
	ON sc.thumbprint = scp.thumbprint
LEFT JOIN sys.asymmetric_keys AS sak
	ON sak.thumbprint = scp.thumbprint
WHERE so.type <> 'U'
ORDER BY SchemaName, ObjectType, ObjectName, CertOrAsymKeyName

/*
Now can PamFromTheOffice run the sproc?
*/
Use SignThoseSprocs 
GO

Execute as login =  'PamFromTheOffice'
EXEC dbo.checksSuccessfulLoginAudit
REVERT