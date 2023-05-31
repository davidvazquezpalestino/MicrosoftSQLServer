SELECT obj.[name] AS [Table Name], col.[name] AS [Column Name], col.[definition] AS [Formula]
FROM sys.Computed_columns AS col
INNER JOIN sys.objects AS obj ON col.object_id = obj.object_id
ORDER BY obj.name, col.name


