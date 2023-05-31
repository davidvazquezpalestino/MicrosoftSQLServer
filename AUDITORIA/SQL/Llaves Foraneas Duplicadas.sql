WITH
ForeignKeys1 AS ( SELECT fk.object_id, OBJECT_NAME (fk.parent_object_id) AS table_name, fk.name AS foreign_key_name, fk.create_date,
                      ( SELECT CAST(parent_object_id AS VARCHAR(50)) + SPACE (1) + CAST(parent_column_id AS VARCHAR(50)) + SPACE (1) + CAST(referenced_object_id AS VARCHAR(50)) + SPACE (1) + CAST(referenced_column_id AS VARCHAR(50)) AS [data()]
                        FROM sys.foreign_key_columns fkc
                        WHERE fk.object_id = fkc.constraint_object_id
                        ORDER BY constraint_column_id
                      FOR XML PATH ('')) foreign_key
                  FROM sys.foreign_keys fk
                  WHERE is_disabled = 0 ),
ForeignKeys2 AS ( SELECT object_id, table_name, foreign_key_name, foreign_key, Duplicidad = COUNT (1) OVER ( PARTITION BY foreign_key ), Partida = ROW_NUMBER () OVER ( PARTITION BY foreign_key
                                                                                                                                                                            ORDER BY foreign_key_name )
                  FROM ForeignKeys1 )
SELECT Tabla = table_name, LlaveForanea = foreign_key_name, SCRIPT = 'ALTER TABLE ' + QUOTENAME (table_name, ']') + ' DROP CONSTRAINT ' + QUOTENAME (foreign_key_name, ']'), ForeignKeys2.Duplicidad
FROM ForeignKeys2
WHERE ForeignKeys2.Duplicidad > 1
ORDER BY table_name, foreign_key_name;
