SELECT Tabla = QUOTENAME ( s.name ) + '.' + QUOTENAME ( t.name ),
       TipoIndice = MAX ( i.type_desc ),
       Grupo = fg.name,
       TieneColumnaIdentity = CASE WHEN c.is_identity = 1 THEN
                                       'Sí'
                                   ELSE
                                       'No'
                              END,
       TablaOptimizadaMemoria = CASE WHEN t.is_memory_optimized = 1 THEN
                                         'Sí'
                                     ELSE
                                         'No'
                                END,
       FechaCreacion = t.create_date,
       UltimaModificacion = t.modify_date,
       Registros = SUM ( p.rows ),
       Kilobytes = SUM ( a.total_pages ) * 8,
       Megabytes = SUM ( a.total_pages ) * 8 / 1024,
       Gigabytes = SUM ( a.total_pages ) * 8 / 1024 / 1024
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partitions p ON  i.object_id = p.object_id
                      AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
LEFT JOIN sys.columns c ON  t.object_id = c.object_id
                        AND c.is_identity = 1
WHERE t.is_ms_shipped = 0
AND   i.type_desc IN ('CLUSTERED', 'NONCLUSTERED')
GROUP BY s.name,
         t.name,
         fg.name,
         t.create_date,
         t.modify_date,
         t.is_memory_optimized,
         c.is_identity
ORDER BY Kilobytes DESC;