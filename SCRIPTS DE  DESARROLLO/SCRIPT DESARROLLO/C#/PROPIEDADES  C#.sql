
DECLARE @tabla AS VARCHAR(100)='tSATCadenaPago'
DECLARE @Entidad AS VARCHAR(100)='CadenaPago'

DECLARE @Table AS TABLE(Id INT IDENTITY (1,1), Comando VARCHAR(MAX))

INSERT INTO @Table
(
    Comando
)

SELECT 'public '+ CASE	WHEN DATA_TYPE = 'varchar'				THEN 'string' 
						WHEN DATA_TYPE = 'numeric'				THEN 'decimal'
						WHEN DATA_TYPE = 'bit'					THEN 'bool'
						WHEN DATA_TYPE IN ('int','tinyint')		THEN 'int'
						WHEN DATA_TYPE IN( 'date', 'datetime')	THEN 'DateTime'
						WHEN DATA_TYPE = 'decimal'				THEN 'decimal'
						WHEN DATA_TYPE = 'smallint'				THEN 'int'
						WHEN DATA_TYPE IN('varbinary') THEN 'byte[]' 
						WHEN DATA_TYPE IN('hierarchyid') THEN '' 
					END + ' ' +COLUMN_NAME + '{ get; set; }' AS Propiedades
													  
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE <> 'uniqueidentifier' AND TABLE_NAME = @tabla

INSERT INTO @Table
(
    Comando
)

SELECT 'public Dm' + @Entidad + '(){}
 public Dm' + @Entidad + '(DataRow Row){}'+ 
'public Dm' + @Entidad + '(SqlDataReader Row){}'+ ''

FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = @tabla

SELECT *
FROM @Table

SELECT COLUMN_NAME +' = '+	CASE	WHEN DATA_TYPE ='varchar'	THEN 'FStr' 
																WHEN DATA_TYPE ='numeric'				THEN 'FDec'
																WHEN DATA_TYPE ='bit'					THEN 'FBool'
																WHEN DATA_TYPE ='decimal'				THEN 'FDec'
																WHEN DATA_TYPE IN ('int','tinyint')		THEN 'FInt'
																WHEN DATA_TYPE IN('date', 'datetime')	THEN 'FDate'
																WHEN DATA_TYPE='smallint'				THEN 'FInt'
																WHEN DATA_TYPE IN('varbinary') THEN 'FByte' 
														END + '(ref pRow, "' +COLUMN_NAME+ '"); '	AS pRow			  													  
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE <> 'uniqueidentifier' AND TABLE_NAME = @tabla


SELECT ''+COLUMN_NAME+' = Row.'+	CASE	WHEN DATA_TYPE ='varchar'THEN 'FStr' 
							WHEN DATA_TYPE ='numeric'				THEN 'FDec'
							WHEN DATA_TYPE ='bit'					THEN 'FBool'
							WHEN DATA_TYPE ='decimal'				THEN 'FDec'
							WHEN DATA_TYPE IN ('int','tinyint')		THEN 'FInt'
							WHEN DATA_TYPE IN('date', 'datetime')	THEN 'FDate'
							WHEN DATA_TYPE='smallint'				THEN 'FInt'
							WHEN DATA_TYPE IN('varbinary') THEN 'FByte' 
					END + '("'+COLUMN_NAME+'");'  AS ex													  
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE <> 'uniqueidentifier' AND TABLE_NAME = @tabla


