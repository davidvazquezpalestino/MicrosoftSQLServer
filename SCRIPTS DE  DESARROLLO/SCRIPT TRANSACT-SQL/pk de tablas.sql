

SELECT	Tabla = OBJECT_NAME(IndiceColumna.object_id), 		
		Columna = COL_NAME(IndiceColumna.object_id, IndiceColumna.column_id)
FROM sys.indexes AS Indice
INNER JOIN sys.index_columns AS IndiceColumna ON Indice.object_id = IndiceColumna.object_id AND Indice.index_id = IndiceColumna.index_id AND Indice.is_primary_key = 1
INNER JOIN sys.tables Tabla ON Tabla.name = OBJECT_NAME(IndiceColumna.object_id)




