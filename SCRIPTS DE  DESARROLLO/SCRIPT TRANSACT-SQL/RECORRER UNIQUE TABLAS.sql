
DECLARE cPK CURSOR FOR

select si.Object_id,si.Index_Id,so.name,si.name,si.type_desc,si.is_unique 
from sys.indexes si join sys.objects so on so.object_id = si.object_id and so.type = 'U' and si.is_Primary_key = 0 and si.type_desc <> 'HEAP' and si.is_unique = 1
order by so.name

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
SET @PKSQL = 'IF EXISTS(SELECT * FROM SYS.INDEXES WHERE NAME = '''+@IndexName+''') DROP INDEX ' + @IndexName + ' ON ' + @TableName 

-- Print the Alternate key statement
PRINT @PKSQL

FETCH NEXT FROM cPK INTO @ObjectID,@IndexId,@TableName,@IndexName,@indexType,@IndexUnique
END
CLOSE cPK
DEALLOCATE cPK
