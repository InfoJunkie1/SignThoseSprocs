Use SignThoseSprocs
GO

SELECT * FROM dbo.favoriteFoods

/*
Can KatieArchivesMedievalHistory execute our sproc?
*/

EXECUTE AS USER = 'KatieArchivesMedievalHistory'
EXEC dbo.truncateFavoriteFoods
REVERT

GO

--grant KatieArchivesMedievalHistory execute on our sproc
GRANT EXECUTE ON dbo.truncateFavoriteFoods to KatieArchivesMedievalHistory

--Execute our sproc using KatieArchivesMedievalHistory context
EXECUTE AS USER = 'KatieArchivesMedievalHistory'
EXEC dbo.truncateFavoriteFoods
REVERT

GO

/*
Create self-signed cert
*/
CREATE CERTIFICATE TruncateCert
ENCRYPTION BY PASSWORD = 'Password4TruncateCert' --use real password and put in password manager
WITH SUBJECT = 'Cert for truncate'

/*
Sign sproc with cert
*/
ADD SIGNATURE TO dbo.truncateFavoriteFoods
BY CERTIFICATE TruncateCert
WITH PASSWORD = 'Password4TruncateCert'

/*
Create user from cert
*/
CREATE USER TruncateCert_user
FROM CERTIFICATE TruncateCert

/*
Grant user needed perms
*/
GRANT ALTER ON SCHEMA::dbo TO TruncateCert_user

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
Now we're going to try having KatieArchivesMedievalHistory run that sproc again
*/
EXECUTE AS USER = 'KatieArchivesMedievalHistory'
EXEC dbo.truncateFavoriteFoods
REVERT

GO
