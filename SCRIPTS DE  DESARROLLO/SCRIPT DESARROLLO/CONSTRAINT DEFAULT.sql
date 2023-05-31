DECLARE @Tabla AS varchar(100)='tCNTcuentas';

SELECT 'IF EXISTS(SELECT * FROM SYS.COLUMNS WHERE OBJECT_ID = OBJECT_ID('''+@Tabla+''') AND NAME = '''+COLUMN_NAME+''')' + CHAR(13)+
	'ALTER TABLE dbo.' + @Tabla + ' ADD CONSTRAINT DF_' + @Tabla + '_' + 
	COLUMN_NAME +	CASE	WHEN DATA_TYPE IN ('varchar', 'xml')						THEN ' DEFAULT ''''	FOR ' + COLUMN_NAME + '' + CHAR(13) + CHAR(13)
							WHEN DATA_TYPE IN ('numeric', 'decimal')					THEN ' DEFAULT 0 FOR ' + COLUMN_NAME + '' + CHAR(13) + CHAR(13)
							WHEN DATA_TYPE IN ('bit')									THEN ' DEFAULT 0 FOR ' + COLUMN_NAME + '' + CHAR(13) + CHAR(13)
							WHEN DATA_TYPE IN ('int', 'bigint', 'smallint', 'tinyint')	THEN ' DEFAULT 0 FOR ' + COLUMN_NAME + '' + CHAR(13) +  CHAR(13)
							WHEN DATA_TYPE IN ('date', 'datetime')						THEN ' DEFAULT ' + '''19000101'' FOR ' + COLUMN_NAME + '' + CHAR(13) + CHAR(13)
					END 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @Tabla 
