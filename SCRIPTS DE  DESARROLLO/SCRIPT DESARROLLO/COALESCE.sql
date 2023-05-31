
DECLARE @sql VARCHAR(max);
DECLARE @filtro VARCHAR(max);

WITH con as (SELECT IdConsulta FROM tCTLconsultas EXCEPT SELECT IdConsulta FROM iERP_CAZ.dbo.tCTLconsultas)

SELECT @Sql = COALESCE(@Sql + ', ', '') + CAST(IdConsulta AS VARCHAR(100)) 
FROM con

SET @Filtro = 'IdConsulta IN('+@Sql+')'


EXECUTE spGenerarInsert	@Tabla	= 'tCTLconsultas',
						@Where	= @Filtro



