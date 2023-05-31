DECLARE @tabla AS VARCHAR(MAX) = N'';

WITH cPrimaryKeys ( tabla, columna, Squema ) AS ( SELECT SO.name,
                                          SC.name, 
										  SCHEMA_NAME(so.schema_id)
                                          FROM sys.objects SO
                                          JOIN sys.columns SC ON SO.object_id = SC.object_id
                                          WHERE system_type_id = 56 AND column_id = 1 AND type = 'U' AND NOT SC.name = 'Id' ),
cForeingkeys ( tabla, columna, forenkeys ) AS ( SELECT FK.TABLE_NAME,
                                                CU.COLUMN_NAME,
                                                FK.TABLE_NAME + CU.COLUMN_NAME
                                                FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
                                                JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
                                                JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
                                                JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
                                                JOIN
                                                ( SELECT i1.TABLE_NAME,
                                                  i2.COLUMN_NAME,
                                                  i2.TABLE_NAME AS z
                                                  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1
                                                  JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
                                                  WHERE i1.CONSTRAINT_TYPE = 'PRIMARY KEY' ) PT ON PT.TABLE_NAME = PK.TABLE_NAME
                                                WHERE (
                                                      ( NOT @tabla = '' AND FK.TABLE_NAME = @tabla ) OR @tabla = '' )),
cCamposTabla ( tabla, columna, Esquema  ) AS ( SELECT SO.name,
                                     SC.name, SCHEMA_NAME(so.schema_id)
                                     FROM sys.objects SO
                                     JOIN sys.columns SC ON SO.object_id = SC.object_id
                                     WHERE system_type_id = 56 AND type = 'U' AND NOT column_id = 1 AND
                                                                                                    (
                                                                                                    ( NOT @tabla = '' AND SO.name = @tabla ) OR @tabla = '' ) AND ( SO.name + SC.name ) NOT IN
                                                                                                                                                                  ( SELECT tabla + columna
                                                                                                                                                                    FROM cForeingkeys )),
cScripts ( fk_tabla, fk_columna, pk_tabla, pk_columna, script, ExisteNombre ) AS ( SELECT cCamposTabla.tabla,
                                                                                   cCamposTabla.columna,
                                                                                   cPrimaryKeys.tabla,
                                                                                   cPrimaryKeys.columna,
                                                                                   'IF NOT EXISTS(SELECT NAME FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID(''' +cCamposTabla.Esquema +'.'+ cCamposTabla.tabla + ''') AND NAME = ''FK_' + cCamposTabla.tabla + '_' + cPrimaryKeys.tabla + CASE WHEN NOT cPrimaryKeys.columna = cCamposTabla.columna THEN
                                                                                                                                                                                                                                                                                     REPLACE (cCamposTabla.columna, cPrimaryKeys.columna, '')
                                                                                                                                                                                                                                                                                ELSE ''
                                                                                                                                                                                                                                                                           END + ''')' + CHAR (10) + 'ALTER TABLE '+cCamposTabla.Esquema+'.[' + cCamposTabla.tabla + '] ADD CONSTRAINT [FK_' + cCamposTabla.tabla + '_' + cPrimaryKeys.tabla + CASE WHEN NOT cPrimaryKeys.columna = cCamposTabla.columna THEN
                                                                                                                                                                                                                                                                                                                                                                                                                                      REPLACE (cCamposTabla.columna, cPrimaryKeys.columna, '')
                                                                                                                                                                                                                                                                                                                                                                                                                                 ELSE ''
                                                                                                                                                                                                                                                                                                                                                                                                                            END + '] FOREIGN KEY([' + cCamposTabla.columna + ']) REFERENCES '+cPrimaryKeys.Squema+'.[' + cPrimaryKeys.tabla + '] ([' + cPrimaryKeys.columna + '])' + CHAR (10),
                                                                                   ISNULL (
                                                                                   ( SELECT 'SI'
                                                                                     FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
                                                                                     WHERE CONSTRAINT_NAME = ( 'FK_' + cCamposTabla.tabla + '_' + cPrimaryKeys.tabla + CASE WHEN NOT cPrimaryKeys.columna = cCamposTabla.columna THEN
                                                                                                                                                                                 REPLACE (cCamposTabla.columna, cPrimaryKeys.columna, '')
                                                                                                                                                                            ELSE ''
                                                                                                                                                                       END )), 'No')
                                                                                   FROM cCamposTabla,
                                                                                   cPrimaryKeys
                                                                                   WHERE cCamposTabla.columna LIKE ( cPrimaryKeys.columna + '%' ))
SELECT *
FROM cScripts;
