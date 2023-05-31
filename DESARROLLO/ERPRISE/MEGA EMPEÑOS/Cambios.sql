IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='tFNZdistribucionGastos' AND COLUMN_NAME= 'Codigo')
ALTER TABLE tFNZdistribucionGastos ADD Codigo VARCHAR(32);

IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='tFNZdistribucionGastos' AND COLUMN_NAME= 'Descripcion')
ALTER TABLE tFNZdistribucionGastos ADD Descripcion VARCHAR(128);


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  07/05/2019
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFNZdistribucionGastos'))
	DROP VIEW dbo.vFNZdistribucionGastos
GO

CREATE VIEW dbo.vFNZdistribucionGastos
	AS
SELECT distribucion.IdDistribucionGasto,
	   distribucion.Codigo,
	   distribucion.Descripcion,
       IdBienServicioConcepto = bienServicio.IdBienServicio,
       BienServicioCodigo=bienServicio.Codigo,
       BienServicioDescripcion=bienServicio.Descripcion,
       sucursal.IdSucursal,
       SucursalCodigo=sucursal.Codigo,
       SucursalDescripcion=sucursal.Descripcion,
       centroCosto.IdCentroCostos,
       CentroCostoCodigo=centroCosto.Codigo,
       CentroCostoDescripcion=centroCosto.Descripcion,
       division.IdDivision,
       DivisionCodigo=division.Codigo,
       DivisionDescripcion=division.Descripcion,
       proyecto.IdProyecto,
       ProyectoCodigo=proyecto.Codigo,
       ProyectoDescripcion=proyecto.Descripcion,
       IdEntidad1=entidades1.IdEntidad,
       Entidad1Codigo=entidades1.Codigo,
       Entidad1Descripcion=entidades1.Descripcion,
       IdEntidad2=entidades2.IdEntidad,
       Entidad2Codigo=entidades2.Codigo,
       Entidad2Descripcion=entidades2.Descripcion,
       IdEntidad3=entidades3.IdEntidad,
       Entidad3Codigo=entidades3.Codigo,
       Entidad3Descripcion=entidades3.Descripcion,
       distribucion.Porcentaje,
       estatus.IdEstatus,
       EstatusCodigo=estatus.Codigo,
       EstatusDescripcion=estatus.Descripcion,
       distribucion.IdSesion,
       distribucion.Alta
FROM dbo.tFNZdistribucionGastos		distribucion	WITH(NOLOCK)
INNER JOIN dbo.tGRLbienesServicios	bienServicio		WITH(NOLOCK) ON bienServicio.IdBienServicio = distribucion.IdBienServicioConcepto
INNER JOIN dbo.tCTLsucursales		sucursal			WITH(NOLOCK) ON sucursal.IdSucursal = distribucion.IdSucursal
INNER JOIN dbo.tCNTcentrosCostos    centroCosto			WITH(NOLOCK) ON centroCosto.IdCentroCostos = distribucion.IdCentroCostos
INNER JOIN dbo.tCNTdivisiones       division			WITH(NOLOCK) ON division.IdDivision = distribucion.IdDivision
INNER JOIN dbo.tPRYproyectos        proyecto			WITH(NOLOCK) ON proyecto.IdProyecto = distribucion.IdProyecto
RIGHT JOIN dbo.tCATentidades		entidades1			WITH(NOLOCK) ON entidades1.IdEntidad = distribucion.IdEntidad1
RIGHT JOIN dbo.tCATentidades		entidades2			WITH(NOLOCK) ON entidades2.IdEntidad = distribucion.IdEntidad2
RIGHT JOIN dbo.tCATentidades		entidades3			WITH(NOLOCK) ON entidades3.IdEntidad = distribucion.IdEntidad3
INNER JOIN dbo.tCTLestatus			estatus				WITH(NOLOCK) ON estatus.IdEstatus = distribucion.IdEstatus
INNER JOIN dbo.tCTLsesiones			sesion				WITH(NOLOCK) ON sesion.IdSesion = distribucion.IdSesion


GO



/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  07/05/2019
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vCONdistribucionGastos'))
	DROP VIEW dbo.vCONdistribucionGastos
GO

CREATE VIEW dbo.vCONdistribucionGastos
	AS
SELECT  Distribucion.IdBienServicioConcepto, Distribucion.Codigo, Distribucion.Descripcion, Estatus.IdEstatus, Estatus = Estatus.Descripcion
FROM dbo.tFNZdistribucionGastos Distribucion
INNER JOIN dbo.tCTLestatus Estatus ON Estatus.IdEstatus = Distribucion.IdEstatus
WHERE Distribucion.IdBienServicioConcepto > 0
GROUP BY Distribucion.IdBienServicioConcepto, Distribucion.Codigo, Distribucion.Descripcion, Estatus.IdEstatus, Estatus.Descripcion

GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  07/05/2019
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCRUDdistribucionGastos'))
	DROP PROCEDURE pCRUDdistribucionGastos
GO

CREATE PROCEDURE dbo.pCRUDdistribucionGastos
@TipoOperacion VARCHAR(5) = '', 
@IdDistribucionGasto INT = 0 OUTPUT, 
@Codigo VARCHAR(32) = NULL,
@Descripcion VARCHAR(128) = NULL,
@IdBienServicioConcepto INT = 0, 
@IdSucursal INT = 0, 
@IdCentroCostos INT = 0, 
@IdDivision INT = 0, 
@IdProyecto INT = 0, 
@IdEntidad1 INT = 0, 
@IdEntidad2 INT = 0, 
@IdEntidad3 INT = 0, 
@Porcentaje NUMERIC(18, 6) = 0, 
@IdEstatus INT = 0, 
@IdSesion INT = 0
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
    BEGIN

        DECLARE @Alta AS DATETIME = CURRENT_TIMESTAMP;
        
        IF @TipoOperacion = 'C'
            BEGIN
                INSERT INTO tFNZdistribucionGastos(Codigo, Descripcion, IdBienServicioConcepto, IdSucursal, IdCentroCostos, IdDivision, IdProyecto, IdEntidad1, IdEntidad2, IdEntidad3, Porcentaje, IdEstatus, IdSesion, Alta)
                VALUES(@Codigo, @Descripcion, @IdBienServicioConcepto, @IdSucursal, @IdCentroCostos, @IdDivision, @IdProyecto, @IdEntidad1, @IdEntidad2, @IdEntidad3, @Porcentaje, @IdEstatus, @IdSesion, @alta);
                SET @IdDistribucionGasto = SCOPE_IDENTITY();
            END;
        IF @TipoOperacion = 'R'
            BEGIN
                SELECT Codigo, Descripcion, IdDistribucionGasto, IdBienServicioConcepto, BienServicioCodigo, BienServicioDescripcion, IdSucursal, SucursalCodigo, SucursalDescripcion, IdCentroCostos, CentroCostoCodigo, CentroCostoDescripcion, IdDivision, DivisionCodigo, DivisionDescripcion, IdProyecto, ProyectoCodigo, ProyectoDescripcion, IdEntidad1, Entidad1Codigo, Entidad1Descripcion, IdEntidad2, Entidad2Codigo, Entidad2Descripcion, IdEntidad3, Entidad3Codigo, Entidad3Descripcion, Porcentaje, IdEstatus, EstatusCodigo, EstatusDescripcion, IdSesion, Alta
                FROM dbo.vFNZdistribucionGastos WITH(NOLOCK)
                WHERE (IdBienServicioConcepto = @IdDistribucionGasto OR Codigo = @Codigo);
            END;
        IF @TipoOperacion = 'U'
            BEGIN
                UPDATE tFNZdistribucionGastos SET  Descripcion = @Descripcion, IdBienServicioConcepto = @IdBienServicioConcepto, IdSucursal = @IdSucursal, IdCentroCostos = @IdCentroCostos, IdDivision = @IdDivision, IdProyecto = @IdProyecto, IdEntidad1 = @IdEntidad1, IdEntidad2 = @IdEntidad2, IdEntidad3 = @IdEntidad3, Porcentaje = @Porcentaje, IdEstatus = @IdEstatus, IdSesion = @IdSesion
                FROM tFNZdistribucionGastos
                WHERE IdDistribucionGasto = @IdDistribucionGasto;
            END;
        IF @TipoOperacion = 'D'
            BEGIN
                DELETE FROM tFNZdistribucionGastos
                WHERE IdDistribucionGasto = @IdDistribucionGasto;
            END;
    END;



GO
/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  07/05/2019
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pLSTdistribucionGastos'))
	DROP PROCEDURE pLSTdistribucionGastos
GO

CREATE PROCEDURE dbo.pLSTdistribucionGastos 
@TipoOperacion VARCHAR(25) = ''  ,
@IdBienServicioConcepto AS INT = 0,
@Codigo VARCHAR(32)=''
AS    
SET NOCOUNT ON;   
SET XACT_ABORT ON;    
BEGIN
IF (@TipoOperacion = 'LST' )
BEGIN   
	SELECT IdDistribucionGasto, Codigo, Descripcion, IdBienServicioConcepto, BienServicioCodigo, BienServicioDescripcion, IdSucursal, SucursalCodigo, SucursalDescripcion, IdCentroCostos, CentroCostoCodigo, CentroCostoDescripcion, IdDivision, DivisionCodigo, DivisionDescripcion, IdProyecto, ProyectoCodigo, ProyectoDescripcion, IdEntidad1, Entidad1Codigo, Entidad1Descripcion, IdEntidad2, Entidad2Codigo, Entidad2Descripcion, IdEntidad3, Entidad3Codigo, Entidad3Descripcion, Porcentaje, IdEstatus, EstatusCodigo, EstatusDescripcion, IdSesion, Alta
	FROM dbo.vFNZdistribucionGastos WITH(NOLOCK)
	WHERE  (IdBienServicioConcepto = @IdBienServicioConcepto OR Codigo = @Codigo) AND IdEstatus=1
END   
IF(@TipoOperacion = 'D' )
BEGIN
	DELETE FROM dbo.tFNZdistribucionGastos 
	WHERE IdBienServicioConcepto = @IdBienServicioConcepto
END
END

GO

IF NOT EXISTS(SELECT IdConsulta FROM tCTLconsultas WHERE IdConsulta =  674) 	
INSERT INTO tCTLconsultas(IdConsulta, Descripcion, SQL, IdTipoD, TituloVentana, Filtro, CampoIdPrincipal, CampoEstatusFiltro, CampoFechaFiltro, PeriodicidadFiltro, FechaInicialFiltro, FechaFinalFiltro, CampoValor, CampoCodigo, CampoDescripcion, MaximoRegistrosDesktop, MaximoRegistrosWeb, MaximoRegistrosMovil, AplicaImpresionFormatos, Orden, IdEstatus, UsaGrafica, IdTipoDconsulta) 
VALUES (674, 'Distribución de Gastos', 'SELECT IdBienServicioConcepto, Codigo, Descripcion, Estatus FROM vCONdistribucionGastos', 1582, 'Distribución de Gastos', '', 'IdBienServicioConcepto', 'IdEstatus', '', 0, '19000101', '19000101', '', 'IdBienServicioConcepto', '', 0, 0, 0, 0, '', 1, 0, 1844) 


IF NOT EXISTS(SELECT IdConsulta FROM tCTLformatoColumnas WHERE IdConsulta = 674 AND Nombre = 'Codigo') 
BEGIN
	INSERT INTO tCTLformatoColumnas(IdConsulta, Nombre, NombreAlias, Ancho, Alineacion, Formato, Color, IndiceVisibilidad, EsCalculado, IdUsuario, IdEstatus, TipoFormato, IdConfiguracion) 
	VALUES (674, 'Codigo', 'Código', 15, 1, '', '', 2, 0, 0, 1, 0, 0) 
END
IF NOT EXISTS(SELECT IdConsulta FROM tCTLformatoColumnas WHERE IdConsulta = 674 AND Nombre = 'Descripcion') 
BEGIN
	INSERT INTO tCTLformatoColumnas(IdConsulta, Nombre, NombreAlias, Ancho, Alineacion, Formato, Color, IndiceVisibilidad, EsCalculado, IdUsuario, IdEstatus, TipoFormato, IdConfiguracion) 
	VALUES (674, 'Descripcion', 'Descripción', 30, 1, '', '', 3, 0, 0, 1, 0, 0) 
END
IF NOT EXISTS(SELECT IdConsulta FROM tCTLformatoColumnas WHERE IdConsulta = 674 AND Nombre = 'Estatus') 
BEGIN
	INSERT INTO tCTLformatoColumnas(IdConsulta, Nombre, NombreAlias, Ancho, Alineacion, Formato, Color, IndiceVisibilidad, EsCalculado, IdUsuario, IdEstatus, TipoFormato, IdConfiguracion) 
	VALUES (674, 'Estatus', 'Estatus', 15, 1, '', '', 5, 0, 0, 1, 0, 0) 
END

IF NOT EXISTS(SELECT IdTabla FROM tCTLtablas WHERE IdTabla =  142) 	
	INSERT INTO tCTLtablas(IdTabla, Nombre, Descripcion, Orden, IdEstatus, CampoId, CampoCodigo, CampoDescripcion, CampoOrden, VistaNavegacion, Filtro) 
	VALUES (142, 'Distribución de Gastos', 'Distribución de Gastos', 0, 1, 'IdBienServicioConcepto', 'Codigo', 'Descripcion', 'Codigo', 'vCONdistribucionGastos', 'IdEstatus=1') 

UPDATE r SET r.IdTabla = 142
FROM dbo.tCTLrecursos r
WHERE IdRecurso IN (1232, 1234)



UPDATE t SET t.Filtro = 'IdTipoOperacion = 518 AND IdEstatus IN (1, 13, 18)'
FROM dbo.tCTLtablas t
WHERE IdTabla = 100



