DECLARE @Tabla AS VARCHAR(100) = 'tGRLoperaciones';

SELECT 'IF NOT EXISTS(SELECT 1 FROM sys.columns c WHERE c.name =''' + COLUMN_NAME + ''' AND c.object_id = object_id (''' + @Tabla + '''))' + CHAR (13) + 'BEGIN' + CHAR (13) + '	ALTER TABLE dbo.' + @Tabla + ' ADD ' + COLUMN_NAME + CASE WHEN DATA_TYPE IN ('varchar') THEN ' VARCHAR (' + CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10)) + ') NOT NULL' + ' DEFAULT ''''' + CHAR (13) + 'END' + CHAR (13)
                                                                                                                                                                                                                                              WHEN DATA_TYPE IN ('numeric') THEN ' NUMERIC(18, 2) ' + IIF(COLUMNS.IS_NULLABLE = 'YES', 'NULL', 'NOT NULL DEFAULT 0') + CHAR (13) + 'END' + CHAR (13)
                                                                                                                                                                                                                                              WHEN DATA_TYPE IN ('bit') THEN ' BIT ' + IIF(COLUMNS.IS_NULLABLE = 'YES', 'NULL', 'NOT NULL DEFAULT 0') + CHAR (13) + 'END' + CHAR (13)
                                                                                                                                                                                                                                              WHEN DATA_TYPE IN ('int') THEN ' INT ' + IIF(COLUMNS.IS_NULLABLE = 'YES', 'NULL', 'NOT NULL DEFAULT 0') + CHAR (13) + 'END' + CHAR (13)
                                                                                                                                                                                                                                              WHEN DATA_TYPE IN ('date', 'datetime') THEN +IIF(COLUMNS.IS_NULLABLE = 'YES', 'NULL', 'NOT NULL DEFAULT ''19000101''') + CHAR (13) + 'END' + CHAR (13)
                                                                                                                                                                                                                                              WHEN DATA_TYPE IN ('bigint') THEN ' INT NOT NULL DEFAULT 0 ' + CHAR (13) + 'END' + CHAR (13)
                                                                                                                                                                                                                                         END AS CAMPO,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @Tabla;

SELECT 'IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys where name = ' + CHAR (39) + '' + name + '' + CHAR (39) + ' and parent_object_id = object_id(' + CHAR (39) + '' + @Tabla + '' + CHAR (39) + '))'
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID (@Tabla);
