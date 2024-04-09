Use SignThoseSprocs
GO

EXEC dbo.dynamicFoodsSearch donut --runs with login with sysadmin

--grant AllisonSwimsWithGaters execute on our sproc
GRANT EXECUTE ON dbo.dynamicFoodsSearch to AllisonSwimsWithGators

--Execute our sproc using AllisonSwimsWithGators context
EXECUTE AS USER = 'AllisonSwimsWithGators'
EXEC dbo.dynamicFoodsSearch donut
REVERT

GO

/*
Create self-signed cert
*/
CREATE CERTIFICATE DynamicSelectCert
ENCRYPTION BY PASSWORD = 'Password4DynamicCert' --use real password and put in password manager
WITH SUBJECT = 'Cert for dynamic select'

/*
Sign sproc with cert
*/
ADD SIGNATURE TO dbo.dynamicFoodsSearch
BY CERTIFICATE DynamicSelectCert
WITH PASSWORD = 'Password4DynamicCert'

/*
Create user from cert
*/
CREATE USER DynamicCert_user
FROM CERTIFICATE DynamicSelectCert

/*
Grant user needed perms
*/
GRANT SELECT TO DynamicCert_user

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
Now we're going to try having AllisonSwimsWithGators run that sproc again
*/
EXECUTE AS USER = 'AllisonSwimsWithGators'
EXEC dbo.dynamicFoodsSearch donut
REVERT

GO

/*
What happens if we make a change on our sproc?
*/
--change sproc
Use SignThoseSprocs 
GO

EXECUTE AS USER = 'AllisonSwimsWithGators'
EXEC dbo.dynamicFoodsSearch donut
REVERT

GO

/*
After updates, we need to resign the sproc--you will need that password
*/

USE SignThoseSprocs
GO

ADD SIGNATURE TO dbo.dynamicFoodsSearch
BY CERTIFICATE DynamicSelectCert
WITH PASSWORD = 'Password4DynamicCert'

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

EXECUTE AS USER = 'AllisonSwimsWithGators'
EXEC dbo.dynamicFoodsSearch donut
REVERT

GO