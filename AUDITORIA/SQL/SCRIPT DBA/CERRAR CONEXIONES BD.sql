
SELECT @@spid
 DECLARE @nameBD VARCHAR(100)= DB_NAME(),@sql VARCHAR(500)= ''

SELECT @sql = @sql + ' KILL ' + CAST(spid AS VARCHAR(4)) + ''
FROM dbo.sysprocesses
WHERE DB_NAME(dbid) = @nameBD
AND spid > 50


SELECT @sql
--EXEC (@sql)


 


