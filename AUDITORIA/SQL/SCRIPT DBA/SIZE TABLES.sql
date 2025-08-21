SELECT TableName = QUOTENAME ( Schemas.name ) + '.' + QUOTENAME ( Tables.name ),
       IndexType = MAX ( Indexes.type_desc ),
       IdentityColumn = MAX ( CASE WHEN IdentityColumns.is_identity = 1 THEN
                                       IdentityColumns.name
                                   ELSE
                                       NULL
                              END ),
       PrimaryKeyColumn = MAX ( PrimaryKeyColumns.name ),
       Rows = SUM ( Partitions.rows ),
       Kilobytes = SUM ( AllocationUnits.total_pages ) * 8,
       Megabytes = SUM ( AllocationUnits.total_pages ) * 8 / 1024,
       Gigabytes = SUM ( AllocationUnits.total_pages ) * 8 / 1024 / 1024,
       CreationDate = Tables.create_date,
       LastModified = Tables.modify_date
FROM sys.tables AS Tables
INNER JOIN sys.schemas AS Schemas ON Tables.schema_id = Schemas.schema_id
INNER JOIN sys.indexes AS Indexes ON Tables.object_id = Indexes.object_id
INNER JOIN sys.partitions AS Partitions ON  Indexes.object_id = Partitions.object_id
                                        AND Indexes.index_id = Partitions.index_id
INNER JOIN sys.allocation_units AS AllocationUnits ON Partitions.partition_id = AllocationUnits.container_id
LEFT JOIN sys.columns AS IdentityColumns ON  Tables.object_id = IdentityColumns.object_id
                                         AND IdentityColumns.is_identity = 1
LEFT JOIN sys.indexes AS PKIndexes ON  Tables.object_id = PKIndexes.object_id
                                   AND PKIndexes.is_primary_key = 1
LEFT JOIN sys.index_columns AS PKIndexColumns ON  PKIndexes.object_id = PKIndexColumns.object_id
                                              AND PKIndexes.index_id = PKIndexColumns.index_id
LEFT JOIN sys.columns AS PrimaryKeyColumns ON  Tables.object_id = PrimaryKeyColumns.object_id
                                           AND PKIndexColumns.column_id = PrimaryKeyColumns.column_id
WHERE Tables.is_ms_shipped = 0
AND   Indexes.type_desc IN ('CLUSTERED', 'NONCLUSTERED')
GROUP BY Schemas.name,
         Tables.name,
         Tables.create_date,
         Tables.modify_date
ORDER BY Rows DESC;