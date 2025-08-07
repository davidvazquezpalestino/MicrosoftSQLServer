SELECT [Tabla] = QUOTENAME ( SCH.name ) + '.' + QUOTENAME ( TBL.name ),
       [Registros] = SUM ( PART.rows ),
       [Tiene Índice Clustered] = CASE WHEN COUNT ( DISTINCT IDX.index_id ) > 0 THEN
                                           'Sí'
                                       ELSE
                                           'No'
                                  END,
       [Tiene Columna Identity] = CASE WHEN COUNT ( COL.column_id ) > 0 THEN
                                           'Sí'
                                       ELSE
                                           'No'
                                  END,
       [Optimizada en Memoria] = CASE WHEN TBL.is_memory_optimized = 1 THEN
                                          'Sí'
                                      ELSE
                                          'No'
                                 END,
       [Creada] = CONVERT ( DATE, TBL.create_date ),
       [Última Modificación] = CONVERT ( DATE, TBL.modify_date )
FROM sys.tables TBL
JOIN sys.schemas SCH ON TBL.schema_id = SCH.schema_id
JOIN sys.partitions PART ON  PART.object_id = TBL.object_id
                         AND PART.index_id IN (0, 1)
JOIN sys.allocation_units AU ON PART.partition_id = AU.container_id
LEFT JOIN sys.indexes IDX ON  TBL.object_id = IDX.object_id
                          AND IDX.type = 1 -- Clustered only
LEFT JOIN sys.columns COL ON  TBL.object_id = COL.object_id
                          AND COL.is_identity = 1
WHERE TBL.is_ms_shipped = 0
GROUP BY SCH.name,
         TBL.name,
         TBL.is_memory_optimized,
         TBL.create_date,
         TBL.modify_date
HAVING SUM ( PART.rows ) > 1
ORDER BY [Registros] DESC;