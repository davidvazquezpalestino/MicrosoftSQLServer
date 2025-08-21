SELECT TableName = QUOTENAME ( Schemas.name ) + '.' + QUOTENAME ( Tables.name ),
       Rows = SUM ( Partitions.rows ),
       CreationDate = CONVERT ( DATE, Tables.create_date ),
       LastModifiedDate = CONVERT ( DATE, Tables.modify_date )
FROM sys.tables AS Tables
JOIN sys.schemas AS Schemas ON Tables.schema_id = Schemas.schema_id
JOIN sys.partitions AS Partitions ON  Partitions.object_id = Tables.object_id
                                  AND Partitions.index_id IN (0, 1)
WHERE Tables.is_ms_shipped = 0
GROUP BY Schemas.name,
         Tables.name,        
         Tables.create_date,
         Tables.modify_date
HAVING SUM ( Partitions.rows ) > 1
ORDER BY Rows DESC;