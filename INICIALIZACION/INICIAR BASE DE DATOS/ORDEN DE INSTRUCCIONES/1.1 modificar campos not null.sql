USE iERP_G360;

DECLARE @Tabla AS TABLE
(
    Tabla VARCHAR(254) NOT NULL,
    ColumnName VARCHAR(254) NOT NULL
);

INSERT INTO @Tabla ( Tabla, ColumnName )
SELECT configuracion.Tabla,
       ac.name
FROM sys.all_columns ac
INNER JOIN sys.tables tab ON ac.object_id = tab.object_id
 inner join sys.indexes pk on tab.object_id = pk.object_id 
INNER JOIN [1G].dbo.tINIconfiguraciones configuracion ON tab.name = configuracion.Tabla COLLATE Modern_Spanish_CI_AI
LEFT JOIN sys.default_constraints df ON ac.default_object_id = df.object_id
WHERE df.name IS NULL
      AND ac.is_nullable = 0
      AND configuracion.UsaRegistroCero = 1
	  AND pk.is_primary_key = 0;

DECLARE @sql AS NVARCHAR(MAX);

DECLARE foreach CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
SELECT 'ALTER TABLE ' + a.Tabla + ' ALTER COLUMN ' + a.ColumnName + '  ' + CASE WHEN b.DATA_TYPE = 'varchar' THEN 'VARCHAR (' + CAST(+b.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(32)) + ')'
                                                                                WHEN b.DATA_TYPE = 'numeric' THEN 'NUMERIC (' + CONCAT (b.NUMERIC_PRECISION, ', ', IIF(b.NUMERIC_SCALE = 0, 2, 8)) + ' )'
                                                                                ELSE UPPER (b.DATA_TYPE)
                                                                           END + '; '
FROM @Tabla a
INNER JOIN dbo.vAUDIcolumnas b ON a.Tabla = b.TABLE_NAME
                                  AND a.ColumnName = b.COLUMN_NAME;

OPEN foreach;

FETCH NEXT FROM foreach
INTO @sql;

WHILE @@Fetch_Status = 0
BEGIN
    PRINT @sql;

    EXECUTE ( @sql );

    FETCH NEXT FROM foreach
    INTO @sql;
END;

CLOSE foreach;
DEALLOCATE foreach;


