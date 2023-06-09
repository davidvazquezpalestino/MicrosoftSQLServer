
ALTER PROCEDURE [dbo].[parchivo]
@Nombre as varchar(100) = '', 
@Extension as varchar(50) = '',
@Longitud as decimal(18,0) = 0,
@IdEstatusSincronizacion int = 0,
@IdEstatus int = 0,
@IdRegistro int ,
@documento char(20) ='',
@persona varchar(100)='' ,
@socio char(20)='',
@pathFile nvarchar(250),
@IdRequisito int = 0,
@IdRequisitoD int = 0,
@IdListaD as int = 0,
@IdTipoDdominio as int = 0,
@version int = 0
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

INSERT INTO tblArchivos (Nombre, Extension, IdListaD, Longitud, IdEstatusSincronizacion, IdEstatus, IdRegistro, documento, persona, socio, IdRequisito,IdRequisitoD, pathFile, IdTipoDdominio, version)
	VALUES (@Nombre, @Extension, @IdListaD, @Longitud, @IdEstatusSincronizacion, @IdEstatus, @IdRegistro, @documento, @persona, @socio, @IdRequisito,@IdRequisitoD, @pathFile, @IdTipoDdominio, @version)
SET NOCOUNT OFF;