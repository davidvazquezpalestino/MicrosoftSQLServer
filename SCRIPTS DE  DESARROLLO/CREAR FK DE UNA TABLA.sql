declare @Tabla as varchar(max)= 'tFNZbancos'
SELECT  'ALTER TABLE ' + SCHEMA_NAME(F.schema_id) + '.'
        + OBJECT_NAME(F.parent_object_id) + ' ADD CONSTRAINT ' + F.name
        + ' FOREIGN KEY ' + '(' + COL_NAME(FC.parent_object_id, FC.parent_column_id) + ')'
        + ' REFERENCES ' + SCHEMA_NAME(RefObj.schema_id) + '.'
        + OBJECT_NAME(F.referenced_object_id) + ' ('
        + COL_NAME(FC.referenced_object_id, FC.referenced_column_id) + ')'
FROM    SYS.FOREIGN_KEYS AS F
        INNER JOIN SYS.FOREIGN_KEY_COLUMNS AS FC ON F.OBJECT_ID = FC.constraint_object_id
        INNER JOIN sys.objects RefObj ON RefObj.object_id = f.referenced_object_id
WHERE   OBJECT_NAME(F.parent_object_id) = @Tabla


