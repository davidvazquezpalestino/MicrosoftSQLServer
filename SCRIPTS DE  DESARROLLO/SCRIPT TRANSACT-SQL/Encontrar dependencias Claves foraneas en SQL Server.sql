DECLARE @Tabla AS VARCHAR(MAX) = 'tNOMnominasPercepcionesDeducciones';

SELECT ForeignKey			= fk.NAME,
       TablaPrincipal		= OBJECT_NAME(fk.parent_object_id),
       ColumnaPrincipal		= COL_NAME(fkc.parent_object_id, fkc.parent_column_id),
       TablaReferenciada	= OBJECT_NAME(fk.referenced_object_id),
       ColumnaReferenciada	= COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) 
FROM sys.foreign_keys AS fk
    INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = @Tabla
ORDER BY create_date, modify_date DESC;

