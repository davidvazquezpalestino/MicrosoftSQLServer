SELECT 'IF NOT EXISTS(SELECT * FROM SYS.DEFAULT_CONSTRAINTS WHERE PARENT_OBJECT_ID = OBJECT_ID('''+sys.tables.name+''') AND NAME = '''+ CONCAT('DF_',sys.tables.name,'_',sys.all_columns.name) +''') 
ALTER TABLE dbo.' + SYS.TABLES.NAME + ' ADD CONSTRAINT DF_' + sys.tables.name + '_' + 
	SYS.ALL_COLUMNS.NAME +	CASE	WHEN user_type_id IN (167,231, 241) 		THEN ' DEFAULT ''''	FOR ' + sys.all_columns.name + '' + CHAR(13) -- varchar,nvachar, xml
									WHEN user_type_id IN (108, 106)			THEN ' DEFAULT 0 FOR ' + sys.all_columns.name + '' + CHAR(13) --decimal, numeric
									WHEN user_type_id IN (104)				THEN ' DEFAULT 0 FOR ' + sys.all_columns.name + '' + CHAR(13) --bit
									WHEN user_type_id IN (56, 127, 52, 48)	THEN ' DEFAULT 0 FOR ' + sys.all_columns.name + '' + CHAR(13) --tinyint, smallint, int, bigint
									WHEN user_type_id IN (40, 61)			THEN ' DEFAULT ' + '''19000101'' FOR ' + sys.all_columns.name --date, datetime
							END 
FROM SYS.ALL_COLUMNS 
	INNER JOIN SYS.TABLES ON ALL_COLUMNS.OBJECT_ID = TABLES.OBJECT_ID AND NOT SYS.TABLES.NAME LIKE 'tbl%' AND NOT SYS.TABLES.NAME LIKE 'tmp%' AND SYS.TABLES.NAME <> 'tCTLrecursosTemporales'
	INNER JOIN SYS.SCHEMAS ON TABLES.SCHEMA_ID = SCHEMAS.SCHEMA_ID AND IS_IDENTITY = 0 AND SYS.ALL_COLUMNS.IS_COMPUTED = 0 AND SYS.ALL_COLUMNS.COLUMN_ID <> 1 AND USER_TYPE_ID <> 165
	LEFT JOIN SYS.DEFAULT_CONSTRAINTS ON ALL_COLUMNS.DEFAULT_OBJECT_ID = DEFAULT_CONSTRAINTS.OBJECT_ID 
WHERE SYS.DEFAULT_CONSTRAINTS.NAME IS NULL AND NOT SYS.TABLES.NAME IN('tCTLpermisosBorrados',
																	  'tCTLconsultas201408030216','tempTCTLdominiosOperaciones','sysdiagrams')



