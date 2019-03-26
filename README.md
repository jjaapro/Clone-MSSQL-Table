# Clone MSSQL table from database to another database

The columns in the table do not need to be defined separately. Only change the values of the variables
```bash
SET @DestinationDatabase = '<database>';
SET @DestinationTableName = '<table>';
SET @SourceTableName = '<table>';
SET @SourceDatabase = '<database>';
```