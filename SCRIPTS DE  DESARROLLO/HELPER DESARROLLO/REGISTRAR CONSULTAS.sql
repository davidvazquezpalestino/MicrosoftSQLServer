
DECLARE @IdConsulta AS INT = (	SELECT
									MAX(IdConsulta) + 1
								FROM tCTLconsultas	)

DECLARE @sql AS VARCHAR(MAX) = 'SELECT * FROM dbo.vCONcuentasPrendario'

/*
1843 Tipos de consulta f3
1844 Tipos de consulta iAnalisis
*/
INSERT INTO tCTLconsultas (IdConsulta, Descripcion, SQL, CampoEstatusFiltro, TituloVentana, IdEstatus, UsaGrafica, IdTipoDconsulta)
	VALUES (@IdConsulta, 'Cuentas', @sql, 'IdEstatus','Cuentas' , 1, 1, 1843 )


SELECT	@IdConsulta AS IdConsulta

DECLARE @WHERE as varchar(100) =  'IdConsulta = '+ CONCAT(@IdConsulta,'') +''

EXECUTE spInserted	@TABLE_NAME = 'tCTLconsultas', @WHERE = @WHERE




