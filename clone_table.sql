DECLARE @DestinationDatabase VARCHAR(100), @SourceDatabase VARCHAR(100);
DECLARE @DestinationTableName VARCHAR(100), @SourceTableName VARCHAR(100)
DECLARE @DestinationColumns VARCHAR(MAX), @SourceColumns VARCHAR(MAX)
DECLARE @SqlCommand NVARCHAR(MAX)

/**********************************/
SET @DestinationDatabase = '<database>';
SET @DestinationTableName = '<table>';
SET @SourceTableName = '<table>';
SET @SourceDatabase = '<database>';
/**********************************/


BEGIN TRY
	BEGIN TRANSACTION
	
	SET @SqlCommand = 'SELECT @Dest = SUBSTRING((
						  SELECT '', '' + QUOTENAME(COLUMN_NAME) 
						  FROM ' + @DestinationDatabase + '.INFORMATION_SCHEMA.COLUMNS 
						  WHERE TABLE_NAME = ''' + @DestinationTableName + ''' 
						  ORDER BY ORDINAL_POSITION FOR XML path('''')),3,200000)'
	EXECUTE sys.sp_executeSQL @SqlCommand, N'@Dest NVARCHAR(MAX) OUTPUT', @Dest = @DestinationColumns OUTPUT
	SET @SqlCommand = 'SELECT @Sour = SUBSTRING((
						  SELECT '', '' + QUOTENAME(COLUMN_NAME) 
						  FROM ' + @SourceDatabase + '.INFORMATION_SCHEMA.COLUMNS 
						  WHERE TABLE_NAME = ''' + @SourceTableName + ''' 
						  ORDER BY ORDINAL_POSITION FOR XML path('''')),3,200000)'
	EXECUTE sys.sp_executeSQL @SqlCommand, N'@Sour NVARCHAR(MAX) OUTPUT', @Sour = @SourceColumns OUTPUT					
	SET @SqlCommand = 'INSERT INTO ' + @DestinationDatabase + '.dbo.' + @DestinationTableName + ' (' + @DestinationColumns + ') ' 
					  + 'SELECT ' + @SourceColumns + ' FROM ' + @SourceDatabase + '.dbo.' + @SourceTableName + ''
	EXECUTE sys.sp_executeSQL @SqlCommand
						
	SET @SqlCommand = 'DELETE FROM '+ @SourceDatabase +'.dbo.' + @SourceTableName	
	EXECUTE sys.sp_executeSQL @SqlCommand

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
	SELECT ERROR_MESSAGE()
	SELECT @Var = ERROR_MESSAGE()
	RAISERROR(@Var, 16,1) WITH LOG
	
	PRINT 'Error occured during transaction. Check ErrorLog.'
END CATCH