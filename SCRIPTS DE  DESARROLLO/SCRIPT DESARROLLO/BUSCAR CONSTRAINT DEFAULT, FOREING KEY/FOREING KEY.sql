SET TRANSACTION ISOLATION LEVEL  READ UNCOMMITTED;
SELECT  c.TablaPrincipal ,
        c.TablaReferencia ,
        c.Campo ,
        c.COUNT ,
        'IF NOT EXISTS (SELECT name FROM sys.foreign_keys WHERE parent_object_id = object_id ('''+ c.TablaPrincipal + ''') AND name = ''' + CONCAT('FK_', c.TablaPrincipal, '_', c.TablaReferencia, '_', c.Campo) + ''')
ALTER TABLE ' + c.TablaPrincipal + ' ADD CONSTRAINT ' + CONCAT('FK_', c.TablaPrincipal, '_', c.TablaReferencia, '_', c.Campo) + ' FOREIGN KEY('+ c.Campo +') REFERENCES ' + c.TablaReferencia + '(' + c.Campo + ') ' + CHAR(13)        
FROM    ( SELECT    TablaPrincipal = OBJECT_NAME(fk.parent_object_id) ,
                    TablaReferencia = OBJECT_NAME(fk.referenced_object_id) ,
                    Campo = COL_NAME(fk.parent_object_id, parent_column_id) ,
                    COUNT = COUNT(COL_NAME(fk.parent_object_id, parent_column_id))
          FROM      sys.foreign_keys fk
                    JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
          GROUP BY  OBJECT_NAME(fk.parent_object_id) ,
                    OBJECT_NAME(fk.referenced_object_id) ,
                    COL_NAME(fk.parent_object_id, parent_column_id)
          HAVING    COUNT(COL_NAME(fk.parent_object_id, parent_column_id)) > 1
        ) AS c;

		

