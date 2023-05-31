DECLARE @DataBaseName AS VARCHAR(100) = DB_NAME();

SELECT [DataBaseName] = DB_NAME ( Estatus.database_id ),
	   [SchemaName] = SCHEMA_NAME(o.schema_id),
       [TableName] = OBJECT_NAME ( Estatus.object_id ),
       [IndexType] = Estatus.index_type_desc,
       [FragmentationPercent] = Estatus.avg_fragmentation_in_percent,
	   [IndexName] = Indice.name       
FROM sys.dm_db_index_physical_stats ( DB_ID (), NULL, NULL, NULL, 'SAMPLED' ) Estatus
INNER JOIN sys.indexes AS Indice ON Estatus.object_id = Indice.object_id AND Estatus.index_id = Indice.index_id
INNER JOIN sys.objects o ON o.object_id = Estatus.object_id
WHERE Estatus.avg_fragmentation_in_percent > 30 AND DB_NAME ( Estatus.database_id ) = @DataBaseName AND Estatus.index_type_desc <> 'HEAP'
ORDER BY Estatus.avg_fragmentation_in_percent DESC;
GO
