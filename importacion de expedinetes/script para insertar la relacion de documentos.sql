
ALTER PROCEDURE pregistrarrelacionExpedientesocio
AS

BEGIN
--columnas de apoyo

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'tDIGarchivos' and COLUMN_NAME = 'Idcontrol')
	ALTER TABLE tDIGarchivos ADD Idcontrol INT NOT NULL DEFAULT 0;

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'tDIGregistrosDocumentos' and COLUMN_NAME = 'IdRequisitoD')
	ALTER TABLE tDIGregistrosDocumentos ADD IdRequisitoD INT NOT NULL DEFAULT 0;

	UPDATE tblArchivos set Longitud = cast((Longitud / 1024) /1024 as NUMERIC(23,8)) 
	from tblArchivos;

	--VALIDAR QUE NO EXISTA EN LA TABLA
	DISABLE TRIGGER trArchivosBitacoraEstatus ON tDIGarchivos;

		INSERT INTO tDIGarchivos(Nombre, Extension, Fecha, IdListaD, Longitud, EsAutogenerado, IdEstatusSincronizacion, IdEstatus, Idcontrol, Version)
		SELECT Nombre, Extension, Fecha, IdListaD, Longitud, 1 as EsAutogenerado, IdEstatusSincronizacion, IdEstatus, IdArchivo, version 
		FROM tblArchivos 
		WHERE NOT EXISTS(SELECT * FROM tDIGarchivos WHERE tblArchivos.Extension = Extension AND tblArchivos.Fecha = Fecha AND
														  tblArchivos.IdListaD = IdListaD AND tblArchivos.Longitud = tDIGarchivos.Longitud);
	ENABLE TRIGGER trArchivosBitacoraEstatus ON tDIGarchivos; 

	DISABLE TRIGGER trRegistroDocumentos ON tDIGregistrosDocumentos;
	--VALIDAR QUE NO EXISTA EN LA TABLA
	INSERT INTO tDIGregistrosDocumentos(IdRegistro, IdArchivo, IdTipoDdominio, Recibido, IdEstatus, IdRequisito, IdRequisitoD, Codigo, Descripcion) 

	SELECT IdRegistro, a.IdArchivo, tbl.IdTipoDdominio, 1 AS recibido, 1 AS idestatus, tbl.IdRequisito, tbl.IdRequisitoD, tbl.socio, tbl.persona
	FROM tDIGarchivos a
	INNER JOIN tblArchivos tbl ON tbl.IdArchivo = a.Idcontrol
	WHERE NOT EXISTS (SELECT 	*
						FROM tDIGregistrosDocumentos
						WHERE tDIGregistrosDocumentos.IdRegistro = tbl.IdRegistro
						AND tDIGregistrosDocumentos.IdArchivo = A.IdArchivo AND tDIGregistrosDocumentos.IdRequisito = tbl.IdRequisito);

	ENABLE TRIGGER trRegistroDocumentos ON tDIGregistrosDocumentos; 

	INSERT INTO tDIGregistrosRequisitos(IdRegistro, IdTipoDdominio, Cubierto, IdRequisito, IdRequisitoD, IdRegistroDocumento, IdEstatus, Codigo, Descripcion)
	SELECT IdRegistro, IdTipoDdominio, 1 as cubierto, IdRequisito, IdRequisitoD, IdRegistroDocumento, 1 AS IdEstatus, Codigo, Descripcion
	FROM tDIGregistrosDocumentos
	WHERE NOT EXISTS(SELECT * 
						FROM tDIGregistrosRequisitos 
						WHERE tDIGregistrosDocumentos.IdRegistro = tDIGregistrosRequisitos.IdRegistro 
						AND tDIGregistrosDocumentos.IdTipoDdominio = tDIGregistrosRequisitos.IdTipoDdominio AND tDIGregistrosDocumentos.IdRequisito = tDIGregistrosRequisitos.IdRequisito
						AND tDIGregistrosDocumentos.IdRegistroDocumento = IdRegistroDocumento AND tDIGregistrosDocumentos.Codigo = tDIGregistrosRequisitos.Codigo)
	--VALIDAR QUE NO EXISTA EN LA TABLA
END


