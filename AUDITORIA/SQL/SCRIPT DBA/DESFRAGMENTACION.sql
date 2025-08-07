SELECT 'ALTER INDEX ' + QUOTENAME ( IND.name ) + ' ON ' + QUOTENAME ( OBJECT_NAME ( IND.object_id )) + CASE WHEN PS.avg_fragmentation_in_percent > 30 THEN
                                                                                                                ' REBUILD'
                                                                                                            WHEN PS.avg_fragmentation_in_percent > 5 THEN
                                                                                                                ' REORGANIZE'
                                                                                                            ELSE
                                                                                                                ''
                                                                                                       END AS QUERY,
       PS.avg_fragmentation_in_percent AS FRAGMENTACION
FROM sys.dm_db_index_physical_stats ( DB_ID (), NULL, NULL, NULL, NULL ) PS
JOIN sys.indexes IND ON  PS.object_id = IND.object_id
                     AND PS.index_id = IND.index_id
WHERE IND.name IS NOT NULL
AND   PS.avg_fragmentation_in_percent > 5
ORDER BY PS.avg_fragmentation_in_percent DESC;