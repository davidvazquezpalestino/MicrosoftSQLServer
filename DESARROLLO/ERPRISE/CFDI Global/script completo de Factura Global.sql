


IF NOT EXISTS(SELECT IdEstatusActual FROM tCTLestatusActual WHERE IdEstatusActual =  -2517) 
BEGIN
SET IDENTITY_INSERT tCTLestatusActual ON;	
	INSERT INTO tCTLestatusActual(IdEstatusActual, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdTipoDDominio, IdObservacionE, IdObservacionEDominio, IdSesion, IdControl) 
	VALUES (-2517, 1, 0, '19000101', -1, '20190218', 141, 0, 0, 0, 0) 
SET IDENTITY_INSERT tCTLestatusActual OFF;
END

IF NOT EXISTS(SELECT IdEstatusActual FROM tCTLestatusActual WHERE IdEstatusActual =  -2516) 
BEGIN
SET IDENTITY_INSERT tCTLestatusActual ON;	
	INSERT INTO tCTLestatusActual(IdEstatusActual, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdTipoDDominio, IdObservacionE, IdObservacionEDominio, IdSesion, IdControl) 
	VALUES (-2516, 1, 0, '19000101', -1, '20190218', 141, 0, 0, 0, 0) 
SET IDENTITY_INSERT tCTLestatusActual OFF;
END
IF NOT EXISTS(SELECT IdEstatusActual FROM tCTLestatusActual WHERE IdEstatusActual =  -2515) 
BEGIN
SET IDENTITY_INSERT tCTLestatusActual ON;	
	INSERT INTO tCTLestatusActual(IdEstatusActual, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdTipoDDominio, IdObservacionE, IdObservacionEDominio, IdSesion, IdControl) 
	VALUES (-2515, 1, 0, '19000101', -1, '20190218', 141, 0, 0, 0, 0) 
SET IDENTITY_INSERT tCTLestatusActual OFF;
END

IF NOT EXISTS(SELECT IdDivision FROM tCNTdivisiones WHERE IdDivision =  -45) 
BEGIN
SET IDENTITY_INSERT tCNTdivisiones ON;	
	INSERT INTO tCNTdivisiones(IdDivision, Codigo, Descripcion, RelCatalogosAsignados, IdEstatusActual, IdCatalogoSITI, IdCatalogoSITIclasificacionCreditoDestino) 
	VALUES (-45, 'ING-INTERES', 'INGRESOS POR INTERESES', -45, -2517, 0, 0) 
SET IDENTITY_INSERT tCNTdivisiones OFF;
END

IF NOT EXISTS(SELECT IdEstructuraCatalogo FROM tGRLestructurasCatalogos WHERE IdEstructuraCatalogo =  -87) 
BEGIN
SET IDENTITY_INSERT tGRLestructurasCatalogos ON;	
	INSERT INTO tGRLestructurasCatalogos(IdEstructuraCatalogo, IdEstructuraContableE, IdClaseD1, IdClaseD2, IdClaseD3, IdClaseD4, IdClaseD5, IdClaseD6, IdTipoDDominio, IdControl) 
	VALUES (-87, -18, 0, 0, 0, 0, 0, 0, 141, 0) 
SET IDENTITY_INSERT tGRLestructurasCatalogos OFF;
END

IF NOT EXISTS(SELECT IdBienServicio FROM tGRLbienesServicios WHERE IdBienServicio =  -2020) 
BEGIN
SET IDENTITY_INSERT tGRLbienesServicios ON;	
	INSERT INTO tGRLbienesServicios(IdBienServicio, IdTipoD, Codigo, Descripcion, DescripcionLarga, CostoEstandar, CostoPromedio, UltimoCosto, PorcentajeDeducible, IdListaDUDM, IdImpuesto, IdImpuestoFronterizo, IdImpuestoCompra, IdImpuestoCompraFronterizo, IdAlmacen, IdEstructuraCatalogo, IdDivision, RelPreciosAsinados, SeCompra, SeVende, RequiereContratacion, IdServicio, MultiApertura, IdEstatusActual, EsComisionApertura, EsGastoCobranza, AplicaPuntoVenta, EsPercepcion, IdTipoDpercepcionDeduccion, IdCuentaABCD, IdAuxiliar, Orden, AplicaGravado, AplicaExento, IdTipoDdeudorPercepcion, Naturaleza, IdTipoDaplicacion, IdTipoDcalculoPersonalizado, IdSATproductoServicio, IdSATunidadMedida, IdTipoDefectoContable, PermiteCambiarPrecioVenta) 
	VALUES (-2020, 100, 'INT-MOR', 'INTERESES MORATORIOS', 'INTERESES MORATORIOS', 0.00000000, 0.00000000, 0.00000000, 0.00000000, 0, 1, 0, 0, 0, 0, -87, -45, 0, 0, 1, 0, 0, 0, -2516, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1524, 0, 1, 1452, 0, 0) 
SET IDENTITY_INSERT tGRLbienesServicios OFF;
END
IF NOT EXISTS(SELECT IdBienServicio FROM tGRLbienesServicios WHERE IdBienServicio =  -2019) 
BEGIN
SET IDENTITY_INSERT tGRLbienesServicios ON;	
	INSERT INTO tGRLbienesServicios(IdBienServicio, IdTipoD, Codigo, Descripcion, DescripcionLarga, CostoEstandar, CostoPromedio, UltimoCosto, PorcentajeDeducible, IdListaDUDM, IdImpuesto, IdImpuestoFronterizo, IdImpuestoCompra, IdImpuestoCompraFronterizo, IdAlmacen, IdEstructuraCatalogo, IdDivision, RelPreciosAsinados, SeCompra, SeVende, RequiereContratacion, IdServicio, MultiApertura, IdEstatusActual, EsComisionApertura, EsGastoCobranza, AplicaPuntoVenta, EsPercepcion, IdTipoDpercepcionDeduccion, IdCuentaABCD, IdAuxiliar, Orden, AplicaGravado, AplicaExento, IdTipoDdeudorPercepcion, Naturaleza, IdTipoDaplicacion, IdTipoDcalculoPersonalizado, IdSATproductoServicio, IdSATunidadMedida, IdTipoDefectoContable, PermiteCambiarPrecioVenta) 
	VALUES (-2019, 100, 'INT-ORD', 'INTERESES ORDINARIOS', 'INTERESES ORDINARIOS', 0.00000000, 0.00000000, 0.00000000, 0.00000000, 0, 1, 0, 0, 0, 0, -87, -45, 0, 0, 1, 0, 0, 0, -2515, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1524, 0, 1, 1452, 0, 0) 
SET IDENTITY_INSERT tGRLbienesServicios OFF;
END
GO

IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tFELfacturaGlobalIngresos')
BEGIN
CREATE TABLE [dbo].[tFELfacturaGlobalIngresos] 
(
	[IdOperacion] INT NOT NULL DEFAULT 0,
	[IdPeriodo] INT NOT NULL DEFAULT 0,
	[IdImpuesto] INT NOT NULL DEFAULT 0,
	[InteresOrdinario] DECIMAL(18, 2) NULL,
	[IVAInteresOrdinario] DECIMAL(18, 2) NULL,
	[InteresMoratorio] DECIMAL(18, 2) NULL,
	[IVAInteresMoratorio] DECIMAL(18, 2) NULL,
	[CargosPagados] DECIMAL(18, 2) NULL,
	[IVACargosPagado] DECIMAL(18, 2) NULL,
	[IdBienServicio] INT NULL,
	[Subtotal] NUMERIC(18, 2) NULL,
	[IVAVenta] NUMERIC(18, 2) NULL,
	[IdOperacionFactura] INT NOT NULL DEFAULT 0 
);

ALTER TABLE [dbo].[tFELfacturaGlobalIngresos] WITH CHECK ADD CONSTRAINT [FK_tFELfacturaGlobalIngresos_IdOperacionFactura] FOREIGN KEY([IdOperacionFactura])REFERENCES [dbo].[tGRLoperaciones]([IdOperacion]);
ALTER TABLE [dbo].[tFELfacturaGlobalIngresos] CHECK CONSTRAINT [FK_tFELfacturaGlobalIngresos_IdOperacionFactura];
 
END

GO


IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='tGRLoperaciones' AND COLUMN_NAME= 'IdOperacionFactura')
ALTER TABLE dbo.tGRLoperaciones ADD IdOperacionFactura INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT OBJECT_ID FROM SYS.FOREIGN_KEYS WHERE PARENT_OBJECT_ID = OBJECT_ID ('tGRLoperaciones') AND name = 'FK_tGRLoperaciones_IdOperacionFactura')
ALTER TABLE dbo.tGRLoperaciones ADD CONSTRAINT FK_tGRLoperaciones_IdOperacionFactura FOREIGN KEY (IdOperacionFactura) REFERENCES tGRLoperaciones ( IdOperacion );

IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tFELfacturaGlobalIngresos' AND COLUMN_NAME='IdOperacionFactura')
ALTER TABLE tFELfacturaGlobalIngresos ADD IdOperacionFactura INT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT object_id FROM sys.foreign_keys WHERE parent_object_id=OBJECT_ID('tFELfacturaGlobalIngresos')AND name='FK_tFELfacturaGlobalIngresos_IdOperacionFactura')
ALTER TABLE dbo.tFELfacturaGlobalIngresos ADD CONSTRAINT FK_tFELfacturaGlobalIngresos_IdOperacionFactura FOREIGN KEY(IdOperacionFactura)REFERENCES dbo.tGRLoperaciones(IdOperacion);

GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  24/02/2020
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFELfacturaGlobalIngresosDetalle'))
	DROP VIEW dbo.vFELfacturaGlobalIngresosDetalle
GO

CREATE VIEW [dbo].[vFELfacturaGlobalIngresosDetalle]
AS
SELECT hhh.IdOperacion,
       Concepto = CONCAT( Bien.Descripcion, ' ', Impuesto.Descripcion ),
       hhh.IdPeriodo,
       hhh.IdImpuesto,
       hhh.Importe,
       hhh.IVA,
       hhh.IdBienServicio
FROM dbo.tGRLbienesServicios Bien
INNER JOIN ( SELECT Comprobante.IdOperacion,
                    Comprobante.IdPeriodo,
                    Comprobante.IdImpuesto,
                    Importe = ISNULL( Comprobante.InteresMoratorio, 0 ),
                    IVA = ISNULL( Comprobante.IVAInteresMoratorio, 0 ),
                    IdBienServicio = -2020, --INTERESES MORATORIOS               
                    Comprobante.IdOperacionFactura
             FROM dbo.tFELfacturaGlobalIngresos Comprobante
             WHERE InteresMoratorio > 0
             UNION
             SELECT IdOperacion,
                    IdPeriodo,
                    IdImpuesto,
                    Importe = ISNULL( Comprobante.InteresOrdinario, 0 ),
                    IVA = ISNULL( Comprobante.IVAInteresOrdinario, 0 ),
                    IdBienServicio = -2019, --INTERESES ORDINARIOS              
                    IdOperacionFactura
             FROM dbo.tFELfacturaGlobalIngresos Comprobante
             WHERE InteresOrdinario > 0
             UNION
             SELECT IdOperacion,
                    IdPeriodo,
                    IdImpuesto,
                    Importe = ISNULL( Comprobante.CargosPagados, 0 ),
                    IVA = ISNULL( Comprobante.IVACargosPagado, 0 ),
                    IdBienServicio, --CARGOS
                    IdOperacionFactura
             FROM dbo.tFELfacturaGlobalIngresos Comprobante
             WHERE CargosPagados > 0
             UNION
             SELECT IdOperacion,
                    IdPeriodo,
                    IdImpuesto,
                    Importe = ISNULL( Comprobante.Subtotal, 0 ),
                    IVA = ISNULL( Comprobante.IVAVenta, 0 ),
                    IdBienServicio, -- VENTAS              
                    IdOperacionFactura
             FROM dbo.tFELfacturaGlobalIngresos Comprobante
             WHERE Subtotal > 0 ) AS hhh ON hhh.IdBienServicio = Bien.IdBienServicio
INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = hhh.IdImpuesto;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  24/02/2020
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vFELfacturaGlobalIngresosResumen'))
	DROP VIEW dbo.vFELfacturaGlobalIngresosResumen
GO

CREATE VIEW dbo.vFELfacturaGlobalIngresosResumen
AS
SELECT Resumen.IdBienServicio,
       Resumen.IdImpuesto,
       Concepto = CONCAT( Bien.Descripcion, ' ', Impuesto.Descripcion ),
       Resumen.Precio,
       PrecioConImpuestos = Precio + ROUND(( Resumen.Precio * Impuesto.TasaIVA ), 2 ),
       Impuestos = ROUND(( Resumen.Precio * Impuesto.TasaIVA ), 2 )
FROM ( SELECT IdBienServicio = -2020, --INTERESES MORATORIOS
              Comprobante.IdImpuesto,
              Precio = SUM( InteresMoratorio ),
              PrecioConImpuestos = SUM( InteresMoratorio ) + SUM( IVAInteresMoratorio ),
              Impuestos = SUM( IVAInteresMoratorio )
       FROM dbo.tFELfacturaGlobalIngresos Comprobante
       WHERE Comprobante.IdOperacionFactura = 0 AND InteresMoratorio > 0
       GROUP BY Comprobante.IdImpuesto
       UNION
       SELECT IdBienServicio = -2019, --INTERESES ORDINARIOS
              IdImpuesto,
              Precio = SUM( InteresOrdinario ),
              PrecioConImpuestos = SUM( InteresOrdinario ) + SUM( IVAInteresOrdinario ),
              Impuestos = SUM( IVAInteresOrdinario )
       FROM dbo.tFELfacturaGlobalIngresos
       WHERE IdOperacionFactura = 0 AND InteresOrdinario > 0
       GROUP BY IdImpuesto
       UNION
       SELECT IdBienServicio, --CARGOS
              IdImpuesto,
              Precio = SUM( CargosPagados ),
              PrecioConImpuestos = SUM( CargosPagados ) + SUM( IVACargosPagado ),
              Impuestos = SUM( IVACargosPagado )
       FROM dbo.tFELfacturaGlobalIngresos
       WHERE IdOperacionFactura = 0 AND CargosPagados > 0
       GROUP BY IdBienServicio,
                IdImpuesto
       UNION
       SELECT IdBienServicio, -- VENTAS
              IdImpuesto,
              Precio = SUM( Subtotal ),
              PrecioConImpuestos = SUM( Subtotal ) + SUM( IVAVenta ),
              Impuestos = SUM( IVAVenta )
       FROM dbo.tFELfacturaGlobalIngresos
       WHERE IdOperacionFactura = 0 AND Subtotal <> 0
       GROUP BY IdBienServicio,
                IdImpuesto ) AS Resumen
INNER JOIN dbo.tGRLbienesServicios Bien ON Bien.IdBienServicio = Resumen.IdBienServicio
INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Resumen.IdImpuesto;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  24/02/2020
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pFELgenerarFacturaGlobal'))
	DROP PROCEDURE pFELgenerarFacturaGlobal
GO

CREATE PROCEDURE dbo.pFELgenerarFacturaGlobal
    @IdPeriodo INT = 0,
    @IdSucursal INT = 0,
    @FechaTrabajo DATE = '19000101',
    @IdComprobante INT = 0 OUTPUT
AS
SET NOCOUNT ON;

BEGIN
    INSERT INTO dbo.tFELfacturaGlobalIngresos ( IdOperacion, IdPeriodo, IdImpuesto, InteresOrdinario, IVAInteresOrdinario, InteresMoratorio, IVAInteresMoratorio, CargosPagados, IVACargosPagado, IdBienServicio )
	SELECT Operacion.IdOperacion,
		   Operacion.IdPeriodo,
		   Operacion.IdImpuesto,
		   Operacion.InteresOrdinario,
		   Operacion.IVAInteresOrdinario,
		   Operacion.InteresMoratorio,
		   Operacion.IVAInteresMoratorio,
		   Operacion.CargosPagados,
		   Operacion.IVACargosPagado,
		   Operacion.IdBienServicio
	FROM ( SELECT
			   --Control
			   Operacion.IdOperacion,
			   Periodo.IdPeriodo,
			   Transaccion.IdImpuesto,
			   --InteresOrdinario
			   InteresOrdinario    = SUM(Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido),--
			   IVAInteresOrdinario = SUM(Transaccion.IVAInteresOrdinarioPagado),
			   -- InteresMoratorio
			   InteresMoratorio    = SUM(Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido),--
			   IVAInteresMoratorio = SUM(Transaccion.IVAInteresMoratorioPagado),
			   --CargosPagados
			   CargosPagados       = SUM(Transaccion.CargosPagados),
			   IVACargosPagado     = SUM(Transaccion.IVACargosPagado),
			   Transaccion.IdBienServicio
		   FROM dbo.tGRLoperaciones							  Operacion WITH ( NOLOCK )
		   INNER JOIN dbo.vSDOtransaccionesFinancierasISNULL Transaccion WITH ( NOLOCK ) ON Transaccion.IdOperacion = Operacion.IdOperacion
		   INNER JOIN dbo.tCTLperiodos							Periodo	WITH ( NOLOCK ) ON Periodo.IdPeriodo = Operacion.IdPeriodo
		   INNER JOIN dbo.tAYCcuentas							 Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuenta = Transaccion.IdCuenta
		   WHERE Transaccion.IdEstatus = 1 AND Operacion.IdEstatus = 1 AND Cuenta.IdTipoDProducto = 143 AND Operacion.IdPeriodo = Periodo.IdPeriodo AND ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados + Transaccion.IVACargosPagado ) > 0 AND Periodo.IdPeriodo = @IdPeriodo
		   GROUP BY Operacion.IdOperacion,
					Periodo.IdPeriodo,
					Transaccion.IdImpuesto,
					Transaccion.IdBienServicio ) AS Operacion
	WHERE NOT EXISTS ( SELECT 1
					   FROM tFELfacturaGlobalIngresos comprobante
					   WHERE Operacion.IdOperacion = comprobante.IdOperacion );

	-- VENTA DE SERVICICIOS 
	INSERT INTO dbo.tFELfacturaGlobalIngresos ( IdOperacion, IdPeriodo, IdImpuesto, IdBienServicio, Subtotal, IVAVenta )
	SELECT Ventas.IdOperacion,
		   @IdPeriodo,
		   Ventas.IdImpuesto,
		   Ventas.IdBienServicio,
		   Ventas.SubTotal,
		   Ventas.IVAVenta
	FROM ( SELECT
			   --control
			   operacion.IdOperacion,
			   Bien.IdBienServicio,
			   Detalle.IdImpuesto,
			   --ventas 
			   SubTotal = SUM(Detalle.Subtotal),
			   IVAVenta = SUM(Detalle.IVA)
		   FROM dbo.tGRLoperaciones            operacion WITH (NOLOCK)
		   INNER JOIN dbo.tCTLperiodos           Periodo WITH (NOLOCK) ON Periodo.IdPeriodo = operacion.IdPeriodo
		   INNER JOIN dbo.tGRLoperacionesD       Detalle WITH (NOLOCK) ON Detalle.RelOperacionD = operacion.IdOperacion
		   INNER JOIN dbo.tGRLoperaciones operacionPadre WITH (NOLOCK) ON operacionPadre.IdOperacion = operacion.IdOperacionPadre
		   INNER JOIN dbo.tGRLbienesServicios       Bien WITH (NOLOCK) ON Bien.IdBienServicio = Detalle.IdBienServicio
		   WHERE operacionPadre.IdPeriodo = @IdPeriodo	AND operacionPadre.IdEstatus = 1 AND Detalle.IdTipoSubOperacion = 17 AND Detalle.Subtotal <> 0 AND Detalle.IdEstatus = 1 -- AND operacion.IdOperacion != operacionPadre.IdOperacion
		   GROUP BY operacion.IdOperacion, Bien.IdBienServicio, Detalle.IdImpuesto ) AS Ventas
	WHERE NOT EXISTS ( SELECT 1
					   FROM tFELfacturaGlobalIngresos b
					   WHERE b.IdBienServicio = Ventas.IdBienServicio );

	IF ( SELECT COUNT(IdOperacion) FROM dbo.tFELfacturaGlobalIngresos WHERE IdOperacionFactura = 0 ) = 0
	BEGIN
		SELECT 'NO SE ENCONTRO NINGÚN MOVIMIENTO';
		RETURN;
	END;

	DECLARE @IdOperacion INT;
	DECLARE @IdTipoOperacion INT = 510;
	DECLARE @Serie VARCHAR(30) = 'FG'
	DECLARE @IdPersona INT = -18
	IF EXISTS (	SELECT 1 FROM dbo.tGRLoperaciones WITH (NOLOCK)	WHERE IdTipoOperacion = 510 AND IdPeriodo = @idPeriodo AND IdEstatus = 1 AND Serie = 'FG' AND Fecha = @FechaTrabajo)
	BEGIN		
		RETURN
		SELECT 'YA SE HA GENERADO UN REISTRO PREVIAMENTE';
	END
	-- Creamos la Operación Padre
	BEGIN
		
		DECLARE @Folio INT,  
				@IdUsuarioAlta INT = -1 ;
		
		DECLARE @IdDivisa INT = 1, 
				@FactorDivisa INT = 1, 
				@IdEstatus INT = 1,  
				@IdListaDPoliza INT = -1, 
				@RequierePoliza INT = 0;
		
		SELECT @IdSucursal = IdSucursal FROM dbo.tCTLsucursales WHERE EsMatriz = 1

		EXEC [dbo].[pLSTseriesRangosFolios] 'LST', @IdTipoOperacion, @Serie, 1, @FechaTrabajo, @Folio OUTPUT;

		INSERT INTO dbo.tGRLoperaciones(Serie, Folio, IdTipoOperacion, Fecha, Concepto, IdPersona, IdPeriodo, IdSucursal, IdDivisa, FactorDivisa, IdListaDPoliza, IdEstatus, IdUsuarioAlta, Alta, RequierePoliza, IdSATmetodoPago, IdSATformaPago, IdUsoCFDI, IdCondicionPago, IdCliente)
		SELECT @Serie, @Folio, @IdTipoOperacion, CURRENT_TIMESTAMP, 'Factura Global Ingresos', @IdPersona, @IdPeriodo, @IdSucursal, @IdDivisa, @FactorDivisa, @IdListaDPoliza, @IdEstatus, @IdUsuarioAlta, CURRENT_TIMESTAMP, @RequierePoliza, IdSATmetodoPago = 1,IdSATformaPago = 1,IdUsoCFDI = 22,IdCondicionPago = -1, IdCliente = -1;
		
		SET @IdOperacion = SCOPE_IDENTITY() ;

		UPDATE  dbo.tGRLoperaciones SET IdOperacionPadre = @IdOperacion
		WHERE IdOperacion = @idOperacion
	END

	INSERT INTO tGRLoperacionesD ( RelOperacionD, IdBienServicio, Partida, IdTipoDDominioDestino, DescripcionBienServicio, IdDivision, IdListaDUDM, Cantidad, PrecioSinImpuestos, PrecioConImpuestos, ImporteSinDescuento, Impuestos, Subtotal, IdImpuesto, Total, IdSucursal, IdEstructuraContableE, Comprobante.IdEstatus, IdTipoDdominio, IdCentroCostos, IdTipoSubOperacion, IdEstatusDominio )
	SELECT IdOperacion           = @IdOperacion,
		   IdBienServicio		 = Resumen.IdBienServicio,
		   Partida               = ROW_NUMBER() OVER ( ORDER BY Precio ),
		   IdTipoDDominioDestino = 0,
		   Resumen.Concepto,
		   IdDivision            = -45, --INGRESOS POR INTERESES
		   IdListaDUDM           = -13, -- NO APLICA
		   Cantidad              = 1,
		   PrecioSinImpuestos    = Resumen.Precio,
		   PrecioConImpuestos,
		   ImporteSinDescuento   = Resumen.Precio,
		   Impuestos			 = Resumen.Impuestos,
		   Subtotal              = Resumen.Precio,
		   Resumen.IdImpuesto,
		   Total                 = Resumen.PrecioConImpuestos,
		   IdSucursal            = @IdSucursal,
		   IdEstructuraContableE = -18, -- servicios
		   IdEstatus             = 1,
		   IdTipoDdominio        = 761, --OPERACIÓN DETALLE
		   IdCentroCostos        = 0,
		   IdTipoSubOperacion    = @IdTipoOperacion, --FACTURA
		   IdEstatusDominio      = 1
	FROM dbo.vFELfacturaGlobalIngresosResumen Resumen
	INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Resumen.IdImpuesto
	OPTION ( RECOMPILE );

	WITH GeneralesEmisor --EMISOR	
	AS ( SELECT IdEmpresa            = Empresa.IdEmpresa,
				IdEmisorProveedor    = Proveedor.IdEmisorProveedor,
				NombreEmisor         = Persona.Nombre,
				RFCEmisor            = Persona.RFC,
				IdDomicilioEmisor    = DomicilioEmisor.IdDomicilio,
				EmisorCalle          = DomicilioEmisor.Calle,
				EmisorEntreCalles    = DomicilioEmisor.Calles,
				EmisorNumeroExterior = DomicilioEmisor.NumeroExterior,
				EmisorNumeroInterior = DomicilioEmisor.NumeroInterior,
				EmisorCodigoPostal   = DomicilioEmisor.CodigoPostal,
				EmisorColonia        = DomicilioEmisor.Asentamiento,
				EmisorLocalidad      = DomicilioEmisor.Ciudad,
				EmisorMunicipio      = DomicilioEmisor.Municipio,
				EmisorEstado         = DomicilioEmisor.Estado,
				EmisorPais           = DomicilioEmisor.Pais,
				IdSATregimenFiscal   = RegimenFiscal.IdSATregimenFiscal,
				RegimenFiscal        = RegimenFiscal.RegimenFiscal
		 FROM dbo.tGRLpersonas                  Persona WITH ( NOLOCK )
		 INNER JOIN dbo.tCTLempresas            Empresa WITH ( NOLOCK ) ON Empresa.IdPersona = Persona.IdPersona
		 INNER JOIN dbo.tSCSemisoresProveedores Proveedor WITH ( NOLOCK ) ON Proveedor.IdPersona = Empresa.IdPersona
		 INNER JOIN dbo.tCATdomicilios          DomicilioEmisor WITH ( NOLOCK ) ON Persona.IdRelDomicilios = DomicilioEmisor.IdRel
		 INNER JOIN dbo.tSATregimenFiscal       RegimenFiscal WITH ( NOLOCK ) ON RegimenFiscal.IdSATregimenFiscal = Empresa.IdRegimenFiscal
		 INNER JOIN dbo.tCTLestatusActual       EstatusDomicilioEmisor WITH ( NOLOCK ) ON EstatusDomicilioEmisor.IdEstatusActual = DomicilioEmisor.IdEstatusActual
		 WHERE EstatusDomicilioEmisor.IdEstatus = 1 AND Empresa.IdEmpresa = 1 ),
		 LugarExpedicion --LUGAR DE EXPEDICION
	AS ( SELECT IdEmpresa                   = 1,
				IdDomicilioExpedicion       = Domicilio.IdDomicilio,
				ExpedicionCalle             = Domicilio.Calle,
				ExpedicionCodigoPostal      = Domicilio.CodigoPostal,
				ExpedicionColonia           = Domicilio.Asentamiento,
				ExpedicionEntreCalles       = Domicilio.Calles,
				ExpedicionEstado            = Domicilio.Estado,
				ExpedicionLocalidad         = Domicilio.Ciudad,
				ExpedicionMunicipio         = Domicilio.Estado,
				ExpedicionNumeroExterior    = Domicilio.NumeroExterior,
				ExpedicionNumeroInterior    = Domicilio.NumeroInterior,
				ExpedicionPais              = Domicilio.Pais,
				CodigoPostalLugarExpedicion = Domicilio.CodigoPostal
		 FROM dbo.tCTLempresas            Empresa WITH ( NOLOCK )
		 INNER JOIN dbo.tGRLpersonas      Persona WITH ( NOLOCK ) ON Persona.IdPersona = Empresa.IdPersona
		 INNER JOIN dbo.tCATdomicilios    Domicilio WITH ( NOLOCK ) ON Domicilio.IdRel = Persona.IdRelDomicilios
		 INNER JOIN dbo.tCTLestatusActual EstatusDomicilioLugarExpedicion ON EstatusDomicilioLugarExpedicion.IdEstatusActual = Domicilio.IdEstatusActual
		 WHERE EstatusDomicilioLugarExpedicion.IdEstatus = 1 AND Empresa.IdEmpresa = 1 ),
		 GeneralesReceptor -- RECEPTOR
	AS ( 
		SELECT IdEmpresa   = 1,
				IdUsoCFDI  = IdSATusoCFDI,
				UsoCFDI,
				RFCreceptor = 'XEXX010101000',
				NombreReceptor = 'PUBLICO EN GENERAL'
		 FROM dbo.tSATusoCFDI
		 WHERE UsoCFDI = 'P01' ),
		 
		 Comprobante -- COMPROBANTE
	AS ( SELECT IdEmpresa = 1,
				Importe   = SUM(Factura.Precio),
				Impuestos = SUM(Factura.Impuestos)
		 FROM dbo.vFELfacturaGlobalIngresosResumen Factura )

	-- SE INSERTA EL COMPROBANTE

	INSERT INTO tIMPcomprobantesFiscales ( TipoComprobante, IdTipoDComprobante, Fecha, FechaHora, Importe, Subtotal, Impuestos, ImpuestosTrasladados, IdDivisa, TipoCambio, IdDomicilioEmisor, NombreEmisor, RFCEmisor, EmisorCalle, EmisorEntreCalles, EmisorNumeroExterior, EmisorNumeroInterior, EmisorCodigoPostal, EmisorColonia, EmisorLocalidad, EmisorMunicipio, EmisorEstado, EmisorPais, IdDomicilioExpedicion, ExpedicionCalle, ExpedicionEntreCalles, ExpedicionNumeroExterior, ExpedicionNumeroInterior, ExpedicionCodigoPostal, ExpedicionColonia, ExpedicionLocalidad, ExpedicionMunicipio, ExpedicionPais, ExpedicionEstado, RFCReceptor,NombreReceptor, IdEstatus, MetodoPago, FormaPago, CodigoDivisa, Total, IdUsoCfdi, IdSATformaPago, IdSATmetodoPago, CodigoPostalLugarExpedicion, IdSATregimenFiscal, RegimenFiscal, Version, IdEmisorProveedor )
	SELECT TipoComprobante             = 'I',
		   IdTipoDComprobante          = 894,
		   Fecha                       = CURRENT_TIMESTAMP,
		   FechaHora                   = CURRENT_TIMESTAMP,
		   Importe                     = Comprobante.Importe,
		   Subtotal                    = Comprobante.Importe,
		   Impuestos                   = Comprobante.Impuestos,
		   ImpuestosTrasladados        = Comprobante.Impuestos,
		   IdDivisa                    = 1,
		   TipoCambio                  = 1,
		   GeneralesEmisor.IdDomicilioEmisor,
		   GeneralesEmisor.NombreEmisor,
		   RFCEmisor,
		   --Emisor
		   EmisorCalle,
		   EmisorEntreCalles,
		   EmisorNumeroExterior,
		   EmisorNumeroInterior,
		   EmisorCodigoPostal,
		   EmisorColonia,
		   EmisorLocalidad,
		   EmisorMunicipio,
		   EmisorEstado,
		   EmisorPais,
		   IdDomicilioExpedicion,
		   --Expedicion
		   ExpedicionCalle,
		   ExpedicionEntreCalles,
		   ExpedicionNumeroExterior,
		   ExpedicionNumeroInterior,
		   ExpedicionCodigoPostal,
		   ExpedicionColonia,
		   ExpedicionLocalidad,
		   ExpedicionMunicipio,
		   ExpedicionPais,
		   ExpedicionEstado,
		   --Receptor		   
		   RFCreceptor,
		   NombreReceptor,
		   IdEstatus                   = 1,
		   MetodoPago                  = 'PUE',		  
		   FormaPago                   = '01',
		   CodigoDivisa                = 'MXN',
		   Total                       = Comprobante.Importe + Comprobante.Impuestos,
		   IdUsoCfdi				   = IdUsoCfdi,
		   IdSATformaPago              = 1,
		   IdSATmetodoPago             = 1,
		   CodigoPostalLugarExpedicion = GeneralesEmisor.EmisorCodigoPostal,
		   IdSATregimenFiscal		   = GeneralesEmisor.IdSATregimenFiscal,
		   RegimenFiscal			   = GeneralesEmisor.RegimenFiscal,
		   Version                     = '3.3',
		   GeneralesEmisor.IdEmisorProveedor
	FROM GeneralesEmisor
	INNER JOIN GeneralesReceptor ON GeneralesReceptor.IdEmpresa = GeneralesEmisor.IdEmpresa
	INNER JOIN LugarExpedicion ON LugarExpedicion.IdEmpresa = GeneralesEmisor.IdEmpresa
	INNER JOIN Comprobante ON Comprobante.IdEmpresa = GeneralesEmisor.IdEmpresa;


	UPDATE dbo.tFELfacturaGlobalIngresos SET IdOperacionFactura = @IdOperacion
	WHERE IdOperacionFactura = 0

	UPDATE b SET b.IdOperacionFactura = a.IdOperacionFactura
	FROM tFELfacturaGlobalIngresos a
	INNER JOIN dbo.tGRLoperaciones b ON b.IdOperacion = a.IdOperacion
	WHERE a.IdOperacionFactura = @idOperacion
	
	SET @IdComprobante = SCOPE_IDENTITY();
	UPDATE dbo.tGRLoperaciones SET IdComprobante = @IdComprobante
	WHERE IdOperacion = @IdOperacion;

	UPDATE tIMPcomprobantesFiscales SET Folio = Operacion.Folio, Serie = Operacion.Serie
	FROM tIMPcomprobantesFiscales  Comprobante
	INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdComprobante = Comprobante.IdComprobante
	WHERE Operacion.IdOperacion = @IdOperacion;


	INSERT INTO dbo.tIMPcomprobantesFiscalesD ( IdComprobante, Partida, Cantidad, IdUDM, UDM, IdProducto, Codigo, Descripcion, PrecioUnitario, Importe, IdImpuesto, IVA, PrecioConImpuestos, IdOperacionD, IdProductoServicio, IdUnidadMedida, IdSATtipoFactor )
	SELECT Operacion.IdComprobante,
		   Detalle.Partida,
		   Detalle.Cantidad,
		   Detalle.IdListaDUDM,
		   ListaDudm.Descripcion,
		   Detalle.IdBienServicio,
		   Codigo  = '01010101',
		   Detalle.DescripcionBienServicio,
		   Detalle.PrecioSinImpuestos,
		   Detalle.PrecioSinImpuestos,
		   Detalle.IdImpuesto,
		   Detalle.Impuestos,
		   Detalle.PrecioConImpuestos,
		   Detalle.IdOperacionD,
		   IdSATproductoServicio = 1,
		   IdSATunidadMedida     = 1452,
		   IdSATtipoFactor       = IIF(Impuesto.EsExento = 1, 3, 1)
	FROM dbo.tGRLoperaciones           Operacion
	INNER JOIN dbo.tGRLoperacionesD    Detalle ON Detalle.RelOperacionD = Operacion.IdOperacion
	INNER JOIN dbo.tGRLbienesServicios	  Bien ON Bien.IdBienServicio = Detalle.IdBienServicio
	INNER JOIN dbo.tIMPimpuestos      Impuesto ON Impuesto.IdImpuesto = Detalle.IdImpuesto
	INNER JOIN dbo.tCATlistasD ListaDudm ON ListaDudm.IdListaD = Detalle.IdListaDUDM
	WHERE Operacion.IdOperacion = @IdOperacion;
	-----------------------------
	UPDATE dbo.tIMPcomprobantesFiscalesD SET IdProductoServicio = 1, IdUnidadMedida = 1452
	WHERE IdComprobante = @IdComprobante

	-- SE INSERTAN LOS IMPUESTOS DEL COMPROBANTE
	EXECUTE dbo.pImpuestosComprobante @IdComprobante = @IdComprobante;
	
END

GO

