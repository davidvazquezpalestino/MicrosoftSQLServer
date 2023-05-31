DECLARE @sql AS nvarchar (max )
DECLARE foreach CURSOR FOR

-- seccion del select 

SELECT name
FROM iERP.SYS.TRIGGERS EXCEPT SELECT name
FROM iERP_MTC.SYS.TRIGGERS


OPEN foreach
FETCH NEXT FROM foreach INTO @sql
WHILE @@fetch_status = 0
     BEGIN
     
--esto es lo que ejecutare n veces segun el select de arriba   
select OBJECT_DEFINITION(OBJECT_ID(@sql))
--todo el código de más, es pura chachara obligatoria

   
FETCH NEXT FROM foreach INTO @sql
     END
CLOSE foreach
DEALLOCATE foreach
