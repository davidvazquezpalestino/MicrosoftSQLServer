DECLARE @Tabla AS VARCHAR(50) = 'tSCSsociosComerciales'

/*Tablas en donde está este Id*/
SELECT  so.name AS 'Objetos que dependen de'
FROM    sys.objects so
INNER JOIN sys.sysreferences referencia ON so.object_id = referencia.fkeyid
WHERE   so.type = 'U' AND referencia.rkeyid = OBJECT_ID(@Tabla)

/*otros Id en esta tabla*/
SELECT  so.name AS 'Objetos de los que depende'
FROM    sys.objects so
INNER JOIN sys.sysreferences referencia ON so.OBJECT_ID = referencia.rkeyid
WHERE   so.type = 'U' AND referencia.fkeyid = OBJECT_ID(@Tabla)






