
-- Get all existing primary keys
DECLARE cPK CURSOR FOR

SELECT si.object_id, si.Index_Id, so.name, si.name, si.type_desc, si.is_unique 
FROM SYS.INDEXES si 
INNER JOIN SYS.OBJECTS so ON so.OBJECT_ID = si.OBJECT_ID AND so.type = 'U' AND si.is_Primary_key = 0 AND si.type_desc <> 'HEAP' AND si.is_unique = 1
ORDER BY so.name

Declare @ObjectID	int
Declare @IndexID	int
Declare @TableName	nvarchar(50)
Declare @IndexName	nvarchar(50)
declare @IndexType	nvarchar(50)
declare @IndexUnique bit

-- Loop through all the primary keys
OPEN cPK
FETCH NEXT FROM cPK INTO @ObjectID,@IndexId,@TableName,@IndexName,@indexType,@IndexUnique
WHILE (@@FETCH_STATUS = 0)
BEGIN
DECLARE @PKSQL NVARCHAR(4000) SET @PKSQL = ''
Declare @KeyUnique nvarchar(10) set @KeyUnique = ''
if @IndexUnique = 1 set @KeyUnique = 'Unique'
SET @PKSQL = 'Create ' + @KeyUnique + ' ' + @IndexType + ' INDEX ' + @IndexName + ' ON ' + @TableName + ' ('

-- Get all columns for the current key
DECLARE cPKColumn CURSOR FOR

SELECT sc.name
FROM SYS.INDEX_COLUMNS sic 
INNER JOIN SYS.COLUMNS sc ON sc.OBJECT_ID = sic.OBJECT_ID AND sc.column_id = sic.column_id 
WHERE sic.OBJECT_ID = @ObjectID AND sic.Index_id = @IndexID

OPEN cPKColumn

DECLARE @PkColumn SYSNAME
DECLARE @PkFirstColumn BIT SET @PkFirstColumn = 1
-- Loop through all columns and append the sql statement
FETCH NEXT FROM cPKColumn INTO @PkColumn
WHILE (@@FETCH_STATUS = 0)
BEGIN
IF (@PkFirstColumn = 1)SET @PkFirstColumn = 0
ELSE
Begin
	SET @PKSQL = @PKSQL + ', '
end

SET @PKSQL = @PKSQL + @PkColumn

FETCH NEXT FROM cPKColumn INTO @PkColumn
END
CLOSE cPKColumn
DEALLOCATE cPKColumn

SET @PKSQL = @PKSQL + ')'
-- Print the primary key statement
PRINT @PKSQL

FETCH NEXT FROM cPK INTO @ObjectID,@IndexId,@TableName,@IndexName,@indexType,@IndexUnique
END
CLOSE cPK
DEALLOCATE cPK
