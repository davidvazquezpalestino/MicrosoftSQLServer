DECLARE @SQL NVARCHAR(MAX);

SELECT @SQL = STRING_AGG ( 'ALTER INDEX ' + QUOTENAME ( IND.name ) + ' ON ' + QUOTENAME ( OBJECT_NAME ( IND.object_id )) + CASE WHEN PS.avg_fragmentation_in_percent > 30 THEN
                                                                                                                                    ' REBUILD'
                                                                                                                                WHEN PS.avg_fragmentation_in_percent > 5 THEN
                                                                                                                                    ' REORGANIZE'
                                                                                                                                ELSE
                                                                                                                                    ''
                                                                                                                           END,
                           ';' + CHAR ( 13 ) + CHAR ( 10 ))
FROM sys.dm_db_index_physical_stats ( DB_ID (), NULL, NULL, NULL, NULL ) AS PS
JOIN sys.indexes AS IND ON  PS.object_id = IND.object_id
                        AND PS.index_id = IND.index_id
WHERE IND.name IS NOT NULL
AND   PS.avg_fragmentation_in_percent > 5;

PRINT @SQL; -- Optional: review before executing

EXEC sp_executesql @SQL = @SQL;