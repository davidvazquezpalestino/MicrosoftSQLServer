DECLARE @sqlcommand AS NVARCHAR(MAX);

DECLARE foreachIniciarRegistroCero CURSOR FOR WITH cte ( script, [table] ) AS
                                              (
                                              SELECT CHAR (13) + 'IF NOT EXISTS (SELECT 1 FROM ' + SO.name + ' WHERE ' + SC.name + ' = 0) ' + CHAR (13) + 'BEGIN ' + CHAR (13) + IIF(SC.is_identity = 1, '	SET IDENTITY_INSERT [' + SO.name + '] ON; ' + CHAR (13) + ' ', '') + '	INSERT INTO [' + SO.name + '] (' + SC.name + ') VALUES (0);' + CHAR (13) + IIF(SC.is_identity = 1, '	SET IDENTITY_INSERT [' + SO.name + '] OFF; ' + CHAR (13) + ' ', '') + 'END' AS script,
                                                     SO.name
                                              FROM sys.objects SO
                                              INNER JOIN [1G].dbo.tINIconfiguraciones co ON co.Tabla = SO.name COLLATE Modern_Spanish_CI_AI
                                              INNER JOIN sys.columns SC ON SO.object_id = SC.object_id
                                              WHERE SO.name LIKE 'T%'
                                                    AND column_id = 1
                                                    AND SC.user_type_id = 56 ),
                                                   cte2 ( [table], [order] ) AS
                                              ( SELECT PT.TABLE_NAME,
                                                       COUNT (*) * -1
                                                FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
                                                JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
                                                JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
                                                JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
                                                JOIN ( SELECT i1.TABLE_NAME,
                                                              i2.COLUMN_NAME,
                                                              i2.TABLE_NAME AS z
                                                       FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1
                                                       JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
                                                       WHERE i1.CONSTRAINT_TYPE = 'PRIMARY KEY' ) PT ON PT.TABLE_NAME = PK.TABLE_NAME
                                                GROUP BY PT.TABLE_NAME ),
                                                   cte3 ( script, [order] ) AS
                                              ( SELECT cte.script,
                                                       ISNULL ([order], 0)
                                                FROM cte
                                                LEFT JOIN cte2 ON cte.[table] = cte2.[table] )
SELECT script
FROM cte3
ORDER BY [order];

OPEN foreachIniciarRegistroCero;

FETCH NEXT FROM foreachIniciarRegistroCero
INTO @sqlcommand;

WHILE @@Fetch_Status = 0
BEGIN
    BEGIN TRY
        EXEC ( @sqlcommand );
    END TRY
    BEGIN CATCH
        RAISERROR (@sqlcommand, 16, 1);

        RETURN;
    END CATCH;

    FETCH NEXT FROM foreachIniciarRegistroCero
    INTO @sqlcommand;
END;

CLOSE foreachIniciarRegistroCero;
DEALLOCATE foreachIniciarRegistroCero;



