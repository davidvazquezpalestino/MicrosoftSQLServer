/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/04/2019
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
			   InteresOrdinario    = SUM(Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido),
			   IVAInteresOrdinario = SUM(Transaccion.IVAInteresOrdinarioPagado),
			   -- InteresMoratorio
			   InteresMoratorio    = SUM(Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido),
			   IVAInteresMoratorio = SUM(Transaccion.IVAInteresMoratorioPagado),
			   --CargosPagados
			   CargosPagados       = SUM(Transaccion.CargosPagados),
			   IVACargosPagado     = SUM(Transaccion.IVACargosPagado),
			   Transaccion.IdBienServicio
		   FROM dbo.tGRLoperaciones                          Operacion WITH ( NOLOCK )
		   INNER JOIN dbo.vSDOtransaccionesFinancierasISNULL Transaccion WITH ( NOLOCK ) ON Transaccion.IdOperacion = Operacion.IdOperacion
		   INNER JOIN dbo.tCTLperiodos                       Periodo WITH ( NOLOCK ) ON Periodo.IdPeriodo = Operacion.IdPeriodo
		   INNER JOIN dbo.tAYCcuentas                        Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuenta = Transaccion.IdCuenta
		   WHERE Transaccion.IdEstatus = 1 AND Cuenta.IdTipoDProducto = 143 AND Operacion.IdPeriodo = Periodo.IdPeriodo AND ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados + Transaccion.IVACargosPagado ) > 0 AND IdOperacionFactura = 0 AND Periodo.IdPeriodo = @IdPeriodo
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
			   IVAVenta = SUM(operacion.IVA)
		   FROM dbo.tGRLoperaciones            operacion WITH (NOLOCK)
		   INNER JOIN dbo.tCTLperiodos           Periodo WITH (NOLOCK) ON Periodo.IdPeriodo = operacion.IdPeriodo
		   INNER JOIN dbo.tGRLoperacionesD       Detalle WITH (NOLOCK) ON Detalle.RelOperacionD = operacion.IdOperacion
		   INNER JOIN dbo.tGRLoperaciones operacionPadre WITH (NOLOCK) ON operacionPadre.IdOperacion = operacion.IdOperacionPadre
		   INNER JOIN dbo.tGRLbienesServicios       Bien WITH (NOLOCK) ON Bien.IdBienServicio = Detalle.IdBienServicio
		   WHERE operacion.IdTipoOperacion = 17 AND Detalle.IdTipoSubOperacion = 17 AND operacionPadre.IdPeriodo = @IdPeriodo AND Detalle.IdEstatus = 1 AND operacionPadre.IdEstatus = 1 AND operacion.SubTotal > 0 AND operacion.IdOperacion != operacionPadre.IdOperacion AND operacion.IdOperacionFactura = 0
		   GROUP BY operacion.IdOperacion,
					Bien.IdBienServicio,
					Detalle.IdImpuesto ) AS Ventas
	WHERE NOT EXISTS ( SELECT 1
					   FROM tFELfacturaGlobalIngresos b
					   WHERE b.IdBienServicio = Ventas.IdBienServicio );

	IF ( SELECT COUNT(IdOperacion) FROM dbo.tFELfacturaGlobalIngresos
		 WHERE IdOperacionFactura = 0 ) = 0
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
				@IdEstatus INT = 13,  
				@IdListaDPoliza INT = -1, 
				@RequierePoliza INT = 0;
		

		EXEC [dbo].[pLSTseriesRangosFolios] 'LST', @IdTipoOperacion, @Serie, 1, @FechaTrabajo, @Folio OUTPUT;

		INSERT INTO dbo.tGRLoperaciones(Serie, Folio, IdTipoOperacion, Fecha, Concepto, IdSocio, IdPersona, IdPeriodo, IdSucursal, IdDivisa, FactorDivisa, IdListaDPoliza, IdEstatus, IdUsuarioAlta, Alta, RequierePoliza)
		SELECT @Serie, @Folio, @IdTipoOperacion, @FechaTrabajo, 'Factura Global Ingresos', 0, @IdPersona, @IdPeriodo, @IdSucursal, @IdDivisa, @FactorDivisa, @IdListaDPoliza, @IdEstatus, @IdUsuarioAlta, CURRENT_TIMESTAMP, @RequierePoliza;
		
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
		   IdEstatus                   = 13,
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
	WHERE IdOperacionFactura = 0;

	UPDATE Operacion SET Operacion.IdOperacionFactura = @IdOperacion
	FROM dbo.tGRLoperaciones                 Operacion WITH ( NOLOCK )
	INNER JOIN dbo.tFELfacturaGlobalIngresos FacturaGlobal WITH ( NOLOCK ) ON FacturaGlobal.IdOperacion = Operacion.IdOperacion
	WHERE FacturaGlobal.IdOperacionFactura = @IdOperacion;


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
		   Bien.Descripcion,
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

	-- SE INSERTAN LOS IMPUESTOS DEL COMPROBANTE
	EXECUTE dbo.pImpuestosComprobante @IdComprobante = @IdComprobante;
	PRINT CONCAT('IdComprobante = ', @IdComprobante);
END

GO

