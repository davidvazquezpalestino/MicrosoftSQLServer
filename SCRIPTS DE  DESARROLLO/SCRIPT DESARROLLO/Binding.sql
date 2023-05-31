USE intelixDEV

DECLARE @Tabla AS varchar(100) = 'tAYCpaquetesTecnologicos'

SELECT CASE WHEN DATA_TYPE IN ('varchar') THEN 'tx' + COLUMN_NAME
			WHEN DATA_TYPE IN ('bit') THEN 'ck' + COLUMN_NAME
			WHEN DATA_TYPE IN ('date', 'datetime') THEN 'ic' + COLUMN_NAME
	END AS col
FROM INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = @Tabla  AND COLUMN_DEFAULT IS NOT NULL



SELECT 'With ' + CASE	WHEN DATA_TYPE IN ('varchar', 'int','decimal','numeric') THEN 'tx' + COLUMN_NAME
						WHEN DATA_TYPE IN ('bit') THEN 'ck' + COLUMN_NAME
						WHEN DATA_TYPE IN ('date', 'datetime') THEN 'ic' + COLUMN_NAME END + '' + CHAR(13) + CHAR(9) + '.DataBindings.Clear()' + CHAR(13)
	+ '.DataBindings.Add("' + CASE 	WHEN DATA_TYPE IN ('varchar', 'int') THEN 'Texto'
									WHEN DATA_TYPE IN ('bit','decimal','numeric') THEN 'Valor'
									WHEN DATA_TYPE IN ('date', 'datetime') THEN 'Valor' END + '", Bsf, "' + COLUMN_NAME + '")' + CHAR(13)
	+ 'End With' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @Tabla AND COLUMN_DEFAULT IS NOT NULL
