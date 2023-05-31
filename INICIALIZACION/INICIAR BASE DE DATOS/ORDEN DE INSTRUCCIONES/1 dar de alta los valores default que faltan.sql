USE iERP_G360;

DECLARE @sql AS NVARCHAR(MAX);

DECLARE foreach CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
SELECT 'IF NOT EXISTS(SELECT 1 FROM SYS.DEFAULT_CONSTRAINTS WHERE PARENT_OBJECT_ID = OBJECT_ID(''' + t.name + ''') AND NAME = ''' + CONCAT ('DF_', t.name, '_', ac.name) + ''') 
ALTER TABLE dbo.' + t.name + ' ADD CONSTRAINT DF_' + t.name + '_' + ac.name + CASE WHEN ac.user_type_id IN (167, 231, 241) THEN ' DEFAULT ''''	FOR ' + ac.name + '' + CHAR (13) -- varchar,nvachar, xml
                                                                                   WHEN ac.user_type_id IN (108, 106) THEN ' DEFAULT 0 FOR ' + ac.name + '' + CHAR (13) --decimal, numeric
                                                                                   WHEN ac.user_type_id IN (104) THEN ' DEFAULT 0 FOR ' + ac.name + '' + CHAR (13) --bit
                                                                                   WHEN ac.user_type_id IN (56, 127, 52, 48) THEN ' DEFAULT 0 FOR ' + ac.name + '' + CHAR (13) --tinyint, smallint, int, bigint
                                                                                   WHEN ac.user_type_id IN (40, 61) THEN ' DEFAULT ' + '''19000101'' FOR ' + ac.name
                                                                                   ELSE NULL
                                                                              END
FROM sys.all_columns ac
JOIN sys.tables t ON ac.object_id = t.object_id
JOIN [1G].dbo.tINIconfiguraciones con ON t.name COLLATE DATABASE_DEFAULT = con.Tabla COLLATE DATABASE_DEFAULT
JOIN sys.schemas sh ON t.schema_id = sh.schema_id
                       AND ac.is_identity = 0
                       AND ac.is_computed = 0
                       AND ac.column_id <> 1
                       AND ac.user_type_id <> 165
LEFT JOIN sys.default_constraints df ON ac.default_object_id = df.object_id
WHERE df.name IS NULL
      AND ac.is_nullable = 0;

OPEN foreach;

FETCH NEXT FROM foreach
INTO @sql;

WHILE @@Fetch_Status = 0
BEGIN
    -- PRINT @sql;
    EXECUTE ( @sql );

    FETCH NEXT FROM foreach
    INTO @sql;
END;

CLOSE foreach;
DEALLOCATE foreach;
