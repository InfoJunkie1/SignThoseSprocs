USE [SignThoseSprocs]
GO

/****** Object:  StoredProcedure [dbo].[truncateFavoriteFoods]    Script Date: 4/5/2024 12:51:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER   PROCEDURE [dbo].[truncateFavoriteFoods]

AS
/******************************************************************************
* Description: blah
*			   	
*			
* Procedure Test: 
	
	EXEC dbo.truncateFavoriteFoods

* Change History:
* -----------------------------------------------------------------------------
* Date			|Author				|Reason
* -----------------------------------------------------------------------------
* 04/04/2024	Sharon Reid		Initial Release
*******************************************************************************/
BEGIN

	SET NOCOUNT ON;
	
	--do stuff
	TRUNCATE TABLE dbo.FavoriteFoods

	SELECT * FROM dbo.FavoriteFoods


END;



GO


