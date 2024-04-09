USE SignThoseSprocs
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE dbo.dynamicFoodsSearch
@searchstr NVARCHAR(MAX)

AS
/******************************************************************************
* Description: searches FavoriteFoods by parameter
* 
* This is a SIGNED sproc			   	
*			
* Procedure Test: 
	
	EXEC dbo.dynamicFoodsSearch blueberries

* Change History:
* -----------------------------------------------------------------------------
* Date			|Author				|Reason
* -----------------------------------------------------------------------------
* 04/04/2024	Sharon Reid		Initial Release
*******************************************************************************/
BEGIN

	SET NOCOUNT ON;
	
	--do stuff
	DECLARE @sql NVARCHAR(MAX)

	SELECT @sql =	'SELECT * FROM dbo.FavoriteFoods
					WHERE FoodName LIKE ''%'' + ''' + @searchstr + ''' + ''%'''
	Exec(@sql)


END;



