SELECT Esquema = s.name,
       Tabla = t.name,
       ROWS = p.rows,
       KB = SUM (a.total_pages) * 8,
       MB = ( SUM (a.total_pages) * 8 ) / 1024,
       GB = (( SUM (a.total_pages) * 8 ) / 1024 ) / 1024
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partitions p ON i.object_id = p.object_id
                         AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_ms_shipped = 0
      AND i.object_id > 255
GROUP BY t.name,
         s.name,
         p.rows
ORDER BY KB DESC;


