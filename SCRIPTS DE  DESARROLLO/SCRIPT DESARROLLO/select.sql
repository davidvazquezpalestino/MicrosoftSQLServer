DECLARE @sql VARCHAR(max) ;
DECLARE @tabla as varchar(50) ='tFELcomprobantes',
		@alias as varchar(50) = 'comprobante'


SELECT  @Sql = COALESCE(@Sql + ', ', '') + CONCAT(@tabla, CAST(COLUMN_NAME AS VARCHAR(100)), ' AS ', CONCAT(@alias, CAST(COLUMN_NAME AS VARCHAR(100)))) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tabla

PRINT @Sql
