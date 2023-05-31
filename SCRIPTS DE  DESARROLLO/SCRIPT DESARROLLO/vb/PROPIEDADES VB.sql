

DECLARE @Tabla AS varchar(100) = 'vIMPcomprobantesNominaNominaVistaPrevia'

SELECT 'Public Property ' + CASE	WHEN DATA_TYPE = 'int' AND ORDINAL_POSITION > 1 AND SUBSTRING(COLUMN_NAME, 1, 2) ='Idx'				THEN '' + REPLACE(COLUMN_NAME, SUBSTRING(COLUMN_NAME, 1, 2), '') + ''ELSE COLUMN_NAME END	+ ' As ' + 
							CASE	WHEN DATA_TYPE = 'varchar'																			THEN 'String'
									WHEN DATA_TYPE IN ('decimal','numeric')																			THEN 'Decimal'
									WHEN DATA_TYPE = 'bit'																				THEN 'Boolean'
									WHEN DATA_TYPE IN ('int','bigint')																	THEN 'Integer'
									WHEN DATA_TYPE IN ('date', 'datetime')															THEN 'New Date(1900,1,1)' ELSE CASE WHEN DATA_TYPE ='int' THEN 'Integer' END END AS Propiedades									
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @Tabla
ORDER BY ORDINAL_POSITION


SELECT COLUMN_NAME  + ' =  ' + CASE	WHEN DATA_TYPE IN ('varchar')			THEN 'DmFormato.FStr'
									WHEN DATA_TYPE IN ('numeric')			THEN 'DmFormato.FDec'
									WHEN DATA_TYPE IN ('bit')				THEN 'DmFormato.FBool'
									WHEN DATA_TYPE IN ('decimal','numeric')	THEN 'DmFormato.FDec'									
									WHEN DATA_TYPE IN ('date', 'datetime')	THEN 'DmFormato.FDate'
									WHEN DATA_TYPE IN ('int','bigint')		THEN 'DmFormato.FInt' ELSE DATA_TYPE END + '(pRow, "' + COLUMN_NAME + '")' AS pRow
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @Tabla
ORDER BY ORDINAL_POSITION


SELECT ''+COLUMN_NAME+' = Row.'+	CASE	WHEN DATA_TYPE ='varchar'THEN 'FStr' 
							WHEN DATA_TYPE ='numeric'				THEN 'FDec'
							WHEN DATA_TYPE ='bit'					THEN 'FBool'
							WHEN DATA_TYPE ='decimal'				THEN 'FDec'
							WHEN DATA_TYPE IN ('int','tinyint')		THEN 'FInt'
							WHEN DATA_TYPE IN('date', 'datetime')	THEN 'FDate'
							WHEN DATA_TYPE='smallint'				THEN 'FInt'
							WHEN DATA_TYPE IN('varbinary') THEN 'FByte' 
					END + '("'+COLUMN_NAME+'")'  													  
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE <> 'uniqueidentifier' AND TABLE_NAME = @tabla
