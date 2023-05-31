DECLARE @Id int,
@TableName varchar(255),
@IndexName varchar(255),
@ColumnName varchar(255)


-- Declaración del cursor

DECLARE foreach CURSOR FOR

SELECT TableName, IndexName, ColumnName 
FROM SYS.TABLES INNER JOIN
	(SELECT  OBJECT_NAME(ic.OBJECT_ID) AS TableName,
			 i.name AS IndexName,
			 COL_NAME(ic.OBJECT_ID, ic.column_id) AS ColumnName
	FROM SYS.INDEXES AS i 
	INNER JOIN SYS.INDEX_COLUMNS AS ic ON i.OBJECT_ID = ic.OBJECT_ID AND i.index_id = ic.index_id and i.is_primary_key = 1 )pk ON TableName = name
WHERE NOT TableName LIKE 'tbl%' AND NOT TableName IN('sysdiagrams')AND NOT TableName  LIKE 'tmp%'
ORDER BY TableName

-- Apertura del cursor

OPEN foreach

-- Lectura de la primera fila del cursor

FETCH foreach INTO  @TableName, @IndexName, @ColumnName

WHILE (@@FETCH_STATUS = 0 )
BEGIN

PRINT 'IF EXISTS (SELECT * FROM dbo.'+@TableName+' WHERE '+@ColumnName+'> 0 ) 
BEGIN 
	PRINT ''SELECT * FROM dbo.'+ @TableName +' WHERE '+@ColumnName+'> 0''
END
'
-- Lectura de la siguiente fila del cursor

FETCH foreach INTO  @TableName, @IndexName, @ColumnName
END

-- Cierre del cursor

CLOSE foreach

-- Liberar los recursos

DEALLOCATE foreach