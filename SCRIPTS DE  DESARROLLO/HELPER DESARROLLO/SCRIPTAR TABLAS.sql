
WITH TABLAS AS
(
SELECT
TABLA  = so.NAME,
ESQUEMA = SCHEMA_NAME( t.schema_id),
SCRIPT = 'CREATE TABLE [dbo].[' + so.name + '] (' + o.list + ')' + CASE
		WHEN tc.Constraint_Name IS NULL THEN ''
		ELSE 'ALTER TABLE ' + so.Name + ' ADD CONSTRAINT ' + tc.Constraint_Name + ' PRIMARY KEY ' + ' (' + LEFT(j.List, LEN(j.List) - 1) + ')'
	END
FROM SYSOBJECTS so
INNER JOIN sys.tables t ON t.name = so.name
CROSS APPLY (SELECT
		'  [' + column_name + '] ' + UPPER(data_type) + CASE data_type	WHEN 'sql_variant' THEN ''
																WHEN 'text' THEN ''
																WHEN 'ntext' THEN ''
																WHEN 'xml' THEN ''
																WHEN 'DECIMAL' THEN '(' + CAST(numeric_precision AS VARCHAR) + ', ' + CAST(numeric_scale AS VARCHAR) + ')'
																WHEN 'NUMERIC' THEN '(' + CAST(numeric_precision AS VARCHAR) + ', ' + CAST(numeric_scale AS VARCHAR) + ')'
																ELSE COALESCE('(' +	CASE 
																						WHEN character_maximum_length = -1 THEN 'MAX' 
																						ELSE CAST(character_maximum_length AS VARCHAR) 
																					END + ')', '')
												END + ' ' +
		CASE
			WHEN EXISTS (SELECT	id
						 FROM syscolumns
						 WHERE OBJECT_NAME(id) = so.name AND name = column_name
						 AND COLUMNPROPERTY(id, name, 'IsIdentity') = 1) THEN 'IDENTITY(' + CAST(IDENT_SEED(so.name) AS VARCHAR) + ',' + CAST(IDENT_INCR(so.name) AS VARCHAR) + ')'
			ELSE ''
		END + ' ' + (CASE WHEN IS_NULLABLE = 'No' THEN 'NOT 'ELSE ''END) + 'NULL ' +
		CASE WHEN INFORMATION_SCHEMA.COLUMNS.COLUMN_DEFAULT IS NOT NULL THEN 'DEFAULT ' + information_schema.columns.COLUMN_DEFAULT	ELSE '' END + ', '

	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE table_name = so.name
	ORDER BY ordinal_position
	FOR XML PATH ('')) o (list)
LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON tc.Table_name = so.Name AND tc.Constraint_Type = 'PRIMARY KEY'
CROSS APPLY (SELECT '[' + Column_Name + '], '
			 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
			 WHERE kcu.Constraint_Name = tc.Constraint_Name
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH ('')) j (list)
			 WHERE xtype = 'U'
			 AND so.name NOT IN ('dtproperties')
)

SELECT SCRIPT = REPLACE(REPLACE(SCRIPT, ' ,   ', ',' + CHAR(10) + ''), ',   ', ',' + CHAR(10) + '')
	   --, TABLAS.TABLA, TABLAS.ESQUEMA
FROM TABLAS
WHERE TABLAS.TABLA LIKE 'tNOM%'

