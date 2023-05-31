SELECT [BD] = DB_NAME (database_id),
       [TYPE] = CASE WHEN type_desc = 'ROWS' THEN 'DATA FILE(S)'
                     WHEN type_desc = 'LOG' THEN 'LOG FILE(S)'
                     ELSE 'SUM'
                END,
       [SIZE IN MB] = CAST((( SUM (size) * 8 ) / 1024.0 ) AS DECIMAL(18, 2)),
       [SIZE IN GB] = CAST(((( SUM (size) * 8 ) / 1024.0 ) / 1024 ) AS DECIMAL(18, 2))
FROM sys.master_files
WHERE database_id = DB_ID (DB_NAME ())
GROUP BY GROUPING SETS((DB_NAME (database_id), type_desc), (DB_NAME (database_id)))
ORDER BY DB_NAME (database_id),
         type_desc DESC;
GO