IF EXISTS(SELECT * FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCRUDregistrosDocumentos'))
DROP PROCEDURE pCRUDregistrosDocumentos
GO


CREATE PROC [dbo].[pCRUDregistrosDocumentos]
@TipoOperacion varchar(5),
@IdRegistroDocumento as int = 0 output,
@IdRegistro as int = 0,
@IdArchivo as int = 0,
@IdTipoDdominio as int = 0,
@IdRegistroDocumentoPadre as int = 0,
@IdDominioTipoDocumento as int = 0,
@Resumen as varchar(150) = '',
@Recibido as bit = 0,
@IdEstatus as int = 0,
@IdUsuarioAlta as int = 0,
@IdRequisito as int = 0,
@IdSesion as int = 0,
@Codigo as varchar(80) = '',
@Descripcion as varchar(256) = '',
@IdPersona as int = 0,
@IdOperacion as int = 0,
@IdTipoOperacion as int = 0,
@FolioOperacion as int = 0,
@FechaOperacion as date = '19000101' 

AS 

SET NOCOUNT ON 
SET XACT_ABORT ON

	
IF (@TipoOperacion='C')
BEGIN
	INSERT INTO [dbo].[tDIGregistrosDocumentos] (IdRegistro, IdArchivo, IdTipoDdominio, IdRegistroDocumentoPadre, IdDominioTipoDocumento, Resumen, Recibido, IdEstatus, IdUsuarioAlta, IdRequisito, IdSesion, Codigo, Descripcion, IdPersona, IdOperacion, IdTipoOperacion, FolioOperacion, FechaOperacion)
	VALUES (@IdRegistro, @IdArchivo, @IdTipoDdominio, @IdRegistroDocumentoPadre, @IdDominioTipoDocumento, @Resumen, @Recibido, @IdEstatus, @IdUsuarioAlta, @IdRequisito, @IdSesion, @Codigo, @Descripcion, @IdPersona, @IdOperacion, @IdTipoOperacion, @FolioOperacion, @FechaOperacion)		
	SET @IdDominioTipoDocumento = SCOPE_IDENTITY()
END
	
IF (@TipoOperacion='R' AND @Idregistrodocumento = 0)
BEGIN
	IF @Codigo=''
		SELECT IdRegistroDocumento, Codigo, Descripcion, IdRegistro, IdArchivo, ArchivoIdArchivoPadre, ArchivoNombre, ArchivoFecha, ArchivoIdListaD, ArchivoListaDCodigo, ArchivoListaDdescripcion, ArchivoLongitud, ArchivoEsAutogenerado, ArchivoVigencia, ArchivoVersion, ArchivoIdEstatusSincronizacion, ArchivoEstatusSincronizacionCodigo, ArchivoEstatusSincronizacionDescripcion, ArchivoEstatusSincronizacionColor, ArchivoIdEstatus, ArchivoIdSesion, RegistroDocumentoIdTipoDdominio, TipoDdominioCodigo, TipoDdominioDescripcion, TipoDdominioDescripcionLarga, TipoDdominioIdTipoE, TipoDdominioIdTipoDPadre, TipoDdominioIdEstatus, IdRegistroDocumentoPadre, RegistroPadreIdRegistro, RegistroPadreIdArchivo, RegistroPadreIdTipoDdominio, RegistroPadreIdRegistroDocumentoPadre, RegistroPadreIdDominioTipoDocumento, IdDominioTipoDocumento, DominioTipoDocumentoIdListaDagrupador, CodigoAgrupador, DescripcionAgrupador, DominioTipoDocumentoIdListaDdocumento, DocumentoCodigo, DocumentoDescripcion, DominioTipoDocumentoIdTipoDdominio, DominioTipoDocumentoEsAuditable, DominioTipoDocumentoEsObligatorio, DominioTipoDocumentoAplicaVigencia, DominioTipoDocumentoEsSistema, DominioTipoDocumentoEsMultidocumento, DominioTipoDocumentoOrden, Resumen, Recibido, IdEstatus, UsuarioAlta, UsuarioCambio, IdTipoDDominio, TipoDominioCodigo, TipoDominioDescripcion, EstatusCodigo, EstatusDescripcion, EstatusColor, IdRequisito, RequisitoCodigo, RequisitoDescripcion, RequisitoEsObligatorioGuardar, RequisitoComportamiento, RequisitoNumMinimoDocumentos, RequisitoIdTipoDDominio, RequisitoIdEstatusActual, IdSesion
		FROM [dbo].[vDIGregistrosDocumentosGUI]
		WHERE (IdRegistroDocumento = @IdRegistroDocumento AND IdEstatus = 1 )
	ELSE
		SELECT IdRegistroDocumento, Codigo, Descripcion, IdRegistro, IdArchivo, ArchivoIdArchivoPadre, ArchivoNombre, ArchivoFecha, ArchivoIdListaD, ArchivoListaDCodigo, ArchivoListaDdescripcion, ArchivoLongitud, ArchivoEsAutogenerado, ArchivoVigencia, ArchivoVersion, ArchivoIdEstatusSincronizacion, ArchivoEstatusSincronizacionCodigo, ArchivoEstatusSincronizacionDescripcion, ArchivoEstatusSincronizacionColor, ArchivoIdEstatus, ArchivoIdSesion, RegistroDocumentoIdTipoDdominio, TipoDdominioCodigo, TipoDdominioDescripcion, TipoDdominioDescripcionLarga, TipoDdominioIdTipoE, TipoDdominioIdTipoDPadre, TipoDdominioIdEstatus, IdRegistroDocumentoPadre, RegistroPadreIdRegistro, RegistroPadreIdArchivo, RegistroPadreIdTipoDdominio, RegistroPadreIdRegistroDocumentoPadre, RegistroPadreIdDominioTipoDocumento, IdDominioTipoDocumento, DominioTipoDocumentoIdListaDagrupador, CodigoAgrupador, DescripcionAgrupador, DominioTipoDocumentoIdListaDdocumento, DocumentoCodigo, DocumentoDescripcion, DominioTipoDocumentoIdTipoDdominio, DominioTipoDocumentoEsAuditable, DominioTipoDocumentoEsObligatorio, DominioTipoDocumentoAplicaVigencia, DominioTipoDocumentoEsSistema, DominioTipoDocumentoEsMultidocumento, DominioTipoDocumentoOrden, Resumen, Recibido, IdEstatus, UsuarioAlta, UsuarioCambio, IdTipoDDominio, TipoDominioCodigo, TipoDominioDescripcion, EstatusCodigo, EstatusDescripcion, EstatusColor, IdRequisito, RequisitoCodigo, RequisitoDescripcion, RequisitoEsObligatorioGuardar, RequisitoComportamiento, RequisitoNumMinimoDocumentos, RequisitoIdTipoDDominio, RequisitoIdEstatusActual, IdSesion
		FROM [dbo].[vDIGregistrosDocumentosGUI]
		WHERE (Codigo = @Codigo AND @Idregistrodocumento <> 0)
END

IF (@TipoOperacion='U')
BEGIN
	UPDATE [dbo].[tDIGregistrosDocumentos] 
	SET IdRegistro=@IdRegistro, IdArchivo=@IdArchivo, IdTipoDdominio=@IdTipoDdominio, IdRegistroDocumentoPadre=@IdRegistroDocumentoPadre, IdDominioTipoDocumento=@IdDominioTipoDocumento, Resumen=@Resumen, Recibido=@Recibido, IdEstatus=@IdEstatus, IdRequisito=@IdRequisito, IdSesion=@IdSesion, Codigo=@Codigo, Descripcion=@Descripcion, IdPersona=@IdPersona, IdOperacion=@IdOperacion, IdTipoOperacion=@IdTipoOperacion, FolioOperacion=@FolioOperacion, FechaOperacion=@FechaOperacion
	WHERE (IdRegistroDocumento=@IdRegistroDocumento)
END
	
IF (@TipoOperacion='D')
BEGIN
	UPDATE tDIGregistrosDocumentos SET 	IdEstatus = @Idestatus 
	FROM [dbo].[tDIGregistrosDocumentos] 
	WHERE (NOT IdRegistroDocumento = 0	AND IdRegistroDocumento = @Idregistrodocumento)
END 

