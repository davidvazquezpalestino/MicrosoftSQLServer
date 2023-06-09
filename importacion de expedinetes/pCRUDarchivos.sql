IF EXISTS(SELECT * FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCRUDarchivos'))
DROP PROCEDURE pCRUDarchivos
GO


CREATE PROC [dbo].[pCRUDarchivos]
    @TipoOperacion varchar(5),
    @IdArchivo as int = 0 output,
    @IdArchivoPadre as int = 0,
    @Nombre as varchar(250) = '',
	@Extension as varchar(12) = '',
    @Fecha as date = '19000101',
    @IdListaD as int = 0,
    @Longitud as numeric(23,8) = 0,
    @EsAutogenerado as bit = 0,
    @Vigencia as date = '19000101',
    @Version as int = 0,
	@EsArchivoPadre as bit = 0,
    @IdEstatusSincronizacion as int = 0,
    @IdEstatus as int = 0,
    @IdSesion as int = 0 

AS 

	SET NOCOUNT ON 
	SET XACT_ABORT ON


	
	IF (@TipoOperacion='C')
	BEGIN
		
		INSERT INTO [dbo].[tDIGarchivos] (IdArchivoPadre, Nombre, Extension, Fecha, IdListaD, Longitud, EsAutogenerado, Vigencia, Version, IdEstatusSincronizacion, EsArchivoPadre, IdEstatus, IdSesion)
			VALUES (@Idarchivopadre, @Nombre, @Extension, @Fecha, @Idlistad, @Longitud, @Esautogenerado, @Vigencia, @Version, @Idestatussincronizacion, @EsArchivoPadre, @Idestatus, @Idsesion)
		SET @Idarchivo = SCOPE_IDENTITY();
	END
	
	IF (@TipoOperacion='R')
	BEGIN
		SELECT IdArchivo, IdArchivoPadre, ArchivoPadreIdArchivoPadre, ArchivoPadreNombre, ArchivoPadreFecha, ArchivoPadreIdListaD, ArchivoPadreLongitud, ArchivoPadreEsAutogenerado, ArchivoPadreVigencia, ArchivoPadreVersion, ArchivoPadreIdEstatusSincronizacion, ArchivoPadreIdEstatus, ArchivoPadreIdSesion, Nombre, Extension, Fecha, IdListaD, ListaDCodigo, ListaDDescripcion, ListaDDescripcionLarga, ListaDIdTipoE, ListaDIdListaDPadre, ListaDIdTipoDAgrupador, ListaDIdEstatusActual, Longitud, EsAutogenerado, Vigencia, Version, EsArchivoPadre, IdEstatusSincronizacion, EstatusSincronizacionCodigo, EstatusSincronizacionDescripcion, EstatusSincronizacionColor, IdEstatus, EstatusCodigo, EstatusDescripcion, EstatusColor, IdSesion, SesionIdUsuario, SesionIdPerfil, SesionIdSucursal, SesionIP, SesionHost, SesionInicio, SesionFin, SesionFechaTrabajo, SesionIdVersion
		FROM [dbo].[vDIGarchivosGUI]
		WHERE (IdArchivo = @IdArchivo)
	END

	IF (@TipoOperacion='U')
	BEGIN
		UPDATE [dbo].[tDIGarchivos] 
		SET IdArchivoPadre = @IdArchivoPadre, Nombre = @Nombre, Extension = @Extension, Fecha = @Fecha, IdListaD = @IdListaD, EsAutogenerado = @EsAutogenerado, Vigencia = @Vigencia, Version = @Version, EsArchivoPadre = @EsArchivoPadre, IdEstatusSincronizacion = @IdEstatusSincronizacion, IdEstatus = @IdEstatus, IdSesion = @IdSesion
		WHERE (IdArchivo = @IdArchivo)
	END

	IF (@TipoOperacion='D')
	BEGIN
		UPDATE [dbo].[tDIGarchivos] SET IdEstatus = 2
		FROM [dbo].[tDIGarchivos]
		WHERE IdArchivo = @IdArchivo 
	END
	 
