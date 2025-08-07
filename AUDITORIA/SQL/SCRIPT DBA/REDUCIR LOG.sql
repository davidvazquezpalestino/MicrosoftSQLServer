DECLARE @DBName NVARCHAR(128) = DB_NAME ();
DECLARE @LogFileName NVARCHAR(128);

SELECT @LogFileName = name
FROM sys.database_files
WHERE type_desc = 'LOG';

DECLARE @sql NVARCHAR(MAX) = N'
ALTER DATABASE [' + @DBName + N'] SET RECOVERY SIMPLE;

DBCC SHRINKFILE (@LogFileName, 1);

DBCC SHRINKDATABASE (@DBName);

ALTER DATABASE [' + @DBName + N'] SET RECOVERY FULL;';

EXEC sp_executesql @sql,
                   N'@LogFileName NVARCHAR(128), @DBName NVARCHAR(128)',
                   @LogFileName = @LogFileName,
                   @DBName = @DBName;

SELECT DBName = @DBName,
       LogFileName = @LogFileName;