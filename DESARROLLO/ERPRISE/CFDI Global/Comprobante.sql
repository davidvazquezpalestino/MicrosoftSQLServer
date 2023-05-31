
CREATE PROCEDURE pFELgenerarFacturaGlobal
@IdPeriodo INT = 0
AS
DECLARE @IdComprobante INT = 0;

WITH GeneralesEmisor --EMISOR	
	AS (   SELECT IdEmpresa            = Empresa.IdEmpresa,
				  IdEmisorProveedor = Proveedor.IdEmisorProveedor,
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
				  RegimenFiscal		   = RegimenFiscal.RegimenFiscal

		   FROM dbo.tGRLpersonas						   Persona WITH(NOLOCK)
		   INNER JOIN dbo.tCTLempresas					   Empresa WITH(NOLOCK)ON Empresa.IdPersona = Persona.IdPersona
		   INNER JOIN dbo.tSCSemisoresProveedores	     Proveedor WITH(NOLOCK)ON Proveedor.IdPersona = Empresa.IdPersona
		   INNER JOIN dbo.tCATdomicilios		   DomicilioEmisor WITH(NOLOCK)ON Persona.IdRelDomicilios = DomicilioEmisor.IdRel
		   INNER JOIN dbo.tSATregimenFiscal          RegimenFiscal WITH(NOLOCK)ON RegimenFiscal.IdSATregimenFiscal = Empresa.IdRegimenFiscal
		   INNER JOIN dbo.tCTLestatusActual EstatusDomicilioEmisor WITH(NOLOCK)ON EstatusDomicilioEmisor.IdEstatusActual = DomicilioEmisor.IdEstatusActual
		   WHERE EstatusDomicilioEmisor.IdEstatus = 1 AND Empresa.IdEmpresa = 1),
	LugarExpedicion --LUGAR DE EXPEDICION
	AS (   SELECT IdEmpresa                   = 1,
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
		   FROM dbo.tCTLempresas		   Empresa WITH (NOLOCK)
		   INNER JOIN dbo.tGRLpersonas     Persona WITH (NOLOCK) ON Persona.IdPersona = Empresa.IdPersona AND Persona.IdEmpresa = Empresa.IdEmpresa		  
		   INNER JOIN dbo.tCATdomicilios Domicilio WITH (NOLOCK) ON Domicilio.IdRel = Persona.IdRelDomicilios
		   INNER JOIN dbo.tCTLestatusActual EstatusDomicilioLugarExpedicion ON EstatusDomicilioLugarExpedicion.IdEstatusActual = Domicilio.IdEstatusActual
		   WHERE EstatusDomicilioLugarExpedicion.IdEstatus = 1 AND Empresa.IdEmpresa = 1),
	GeneralesReceptor -- RECEPTOR
	AS (   SELECT IdEmpresa = 1,
				  IdUsoCfdi = IdSATusoCFDI, 
				  UsoCFDI, 
				  RFCreceptor = 'XEXX010101000'
		   FROM dbo.tSATusoCFDI
		   WHERE UsoCFDI = 'P01'),
	Comprobante -- COMPROBANTE
	AS (	SELECT IdEmpresa = 1,
				   Importe   = SUM(InteresOrdinarioPagado+InteresOrdinarioPagadoVencido+InteresMoratorioPagado+InteresMoratorioPagadoVencido+CargosPagados+VentaSubTotal), 
				   Impuestos = SUM(IVACargosPagado+IVAInteresMoratorioPagado+IVAInteresOrdinarioPagado+VentaIVA)				   
			FROM tFELfacturaGlobalIngresos Factura
			LEFT JOIN dbo.tFELestadoCuentaBancario EstadoCuenta ON EstadoCuenta.IdCuenta=Factura.IdCuenta AND EstadoCuenta.IdPeriodo=Factura.IdPeriodo
			WHERE Factura.IdPeriodo = @IdPeriodo AND EstadoCuenta.IdCuenta IS NULL 
			)
	
	-- SE INSERTA EL COMPROBANTE
	INSERT INTO tIMPcomprobantesFiscales(TipoComprobante, IdTipoDComprobante, Serie, Fecha, FechaHora, Importe, Subtotal, Impuestos, ImpuestosTrasladados, IdDivisa, TipoCambio, IdDomicilioEmisor, NombreEmisor, RFCEmisor, EmisorCalle, EmisorEntreCalles, EmisorNumeroExterior, EmisorNumeroInterior, EmisorCodigoPostal, EmisorColonia, EmisorLocalidad, EmisorMunicipio, EmisorEstado, EmisorPais, IdDomicilioExpedicion, ExpedicionCalle, ExpedicionEntreCalles, ExpedicionNumeroExterior, ExpedicionNumeroInterior, ExpedicionCodigoPostal, ExpedicionColonia, ExpedicionLocalidad, ExpedicionMunicipio, ExpedicionPais, ExpedicionEstado, RFCReceptor, IdEstatus, MetodoPago, FormaPago, CodigoDivisa, Total, IdUsoCfdi, IdSATformaPago, IdSATmetodoPago, CodigoPostalLugarExpedicion, IdSATregimenFiscal, RegimenFiscal, Version, IdEmisorProveedor)	
	SELECT TipoComprobante='I', IdTipoDComprobante=894, Serie='G', Fecha=CURRENT_TIMESTAMP, FechaHora=CURRENT_TIMESTAMP, Importe=Comprobante.Importe, Subtotal=Comprobante.Importe, Impuestos=Comprobante.Impuestos, ImpuestosTrasladados=Comprobante.Impuestos, IdDivisa=1, TipoCambio=1, GeneralesEmisor.IdDomicilioEmisor, GeneralesEmisor.NombreEmisor, RFCEmisor,
			--Emisor
		   EmisorCalle, EmisorEntreCalles, EmisorNumeroExterior, EmisorNumeroInterior, EmisorCodigoPostal, EmisorColonia, EmisorLocalidad, EmisorMunicipio, EmisorEstado, EmisorPais, IdDomicilioExpedicion,
			--Expedicion
		   ExpedicionCalle, ExpedicionEntreCalles, ExpedicionNumeroExterior, ExpedicionNumeroInterior, ExpedicionCodigoPostal, ExpedicionColonia, ExpedicionLocalidad, ExpedicionMunicipio, ExpedicionPais, ExpedicionEstado, 
			--Receptor
		   RFCreceptor, IdEstatus=13, MetodoPago='PUE', FormaPago='01', CodigoDivisa='MXN', Total=Comprobante.Importe, IdUsoCfdi, IdSATformaPago=0, IdSATmetodoPago=1, CodigoPostalLugarExpedicion=GeneralesEmisor.EmisorCodigoPostal, GeneralesEmisor.IdSATregimenFiscal, GeneralesEmisor.RegimenFiscal, Version='3.3', GeneralesEmisor.IdEmisorProveedor
	FROM GeneralesEmisor
	INNER JOIN GeneralesReceptor ON GeneralesReceptor.IdEmpresa=GeneralesEmisor.IdEmpresa
	INNER JOIN LugarExpedicion ON LugarExpedicion.IdEmpresa=GeneralesEmisor.IdEmpresa
	INNER JOIN Comprobante ON Comprobante.IdEmpresa = GeneralesEmisor.IdEmpresa
	WHERE NOT EXISTS (	SELECT 1
						FROM tFELestadoCuentaBancario WITH(NOLOCK)
						WHERE IdPeriodo=@IdPeriodo AND IdEstatus = 1 );

	DECLARE @FilasAfectadas INT = @@ROWCOUNT
	IF @FilasAfectadas = 0
	BEGIN
		RAISERROR ('DEBE DE COMUNICARSE CON EL ÁREA PERTINENTE, NO SE GENERÓ EL COMPROBANTE', 16, 8)
	END
	IF (@FilasAfectadas = 1)
	BEGIN
		SET @IdComprobante = SCOPE_IDENTITY();
 		DECLARE @SiguienteFolio INT;
		
		SELECT @SiguienteFolio = MAX(Folio) + 1
		FROM dbo.tIMPcomprobantesFiscales WITH(NOLOCK)
		WHERE IdTipoDComprobante = 894 AND Serie='G';

		UPDATE tIMPcomprobantesFiscales SET Folio = @SiguienteFolio
		FROM tIMPcomprobantesFiscales
		WHERE IdComprobante = @IdComprobante;

		--SE INSERTAN LOS DETALLES DEL COMPROBANTE.
		INSERT INTO dbo.tIMPcomprobantesFiscalesD(IdComprobante, Cantidad, Codigo, Descripcion, PrecioUnitario, Importe, IdImpuesto, IVA, IdProductoServicio, IdUnidadMedida, IdSATtipoFactor)
		--InteresOrdinario
		SELECT @IdComprobante, Cantidad = 1,Codigo ='01010101',
			   Concepto = CONCAT('INTERESES ORDINARIOS', ' ', Impuesto.Descripcion),
			   PrecioUnitario = SUM (InteresOrdinarioPagado + InteresOrdinarioPagadoVencido),
			   Importe = SUM (InteresOrdinarioPagado + InteresOrdinarioPagadoVencido),
			   Impuesto.IdImpuesto,      
			   IVA = SUM (Venta.IVAInteresOrdinarioPagado),
			   IdProductoServicio = 1,
			   IdUnidadMedida = 1358,
			   IdSATtipoFactor = IIF(Impuesto.EsExento = 1, 3, 1)
		FROM tFELfacturaGlobalIngresos Venta
		INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Venta.IdImpuesto
		WHERE Venta.IdPeriodo = @IdPeriodo AND (InteresOrdinarioPagado + InteresOrdinarioPagadoVencido) > 0
		GROUP BY Concepto, Impuesto.IdImpuesto, Impuesto.Descripcion, Impuesto.EsExento;
		--Interes Moratorios
		INSERT INTO dbo.tIMPcomprobantesFiscalesD(IdComprobante, Cantidad, Codigo, Descripcion, PrecioUnitario, Importe, IdImpuesto, IVA, IdProductoServicio, IdUnidadMedida, IdSATtipoFactor)
		SELECT @IdComprobante, Cantidad = 1,Codigo ='01010101',
			   Concepto = CONCAT('INTERESES MORATORIOS', ' ', Impuesto.Descripcion),
			   PrecioUnitario = SUM (InteresMoratorioPagado + InteresMoratorioPagadoVencido),
			   Importe = SUM (InteresMoratorioPagado + InteresMoratorioPagadoVencido),
			   Impuesto.IdImpuesto,      
			   IVA = SUM (IVAInteresMoratorioPagado),
			   IdProductoServicio = 1,
			   IdUnidadMedida = 1358,
			   IdSATtipoFactor = IIF(Impuesto.EsExento = 1, 3, 1)
		FROM tFELfacturaGlobalIngresos Venta
		INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Venta.IdImpuesto
		WHERE Venta.IdPeriodo = @IdPeriodo AND ( InteresMoratorioPagado + InteresMoratorioPagadoVencido ) > 0
		GROUP BY Concepto, Impuesto.IdImpuesto,Impuesto.Descripcion, Impuesto.EsExento;

		--cargos
		INSERT INTO dbo.tIMPcomprobantesFiscalesD(IdComprobante, Cantidad, Codigo, Descripcion, PrecioUnitario, Importe, IdImpuesto, IVA, IdProductoServicio, IdUnidadMedida, IdSATtipoFactor)
		SELECT @IdComprobante, Cantidad = 1,Codigo ='01010101',
			     Concepto = CONCAT(Venta.Concepto, ' ', Impuesto.Descripcion),
			     PrecioUnitario = SUM (CargosPagados),
			     Importe = SUM (CargosPagados),
			     Impuesto.IdImpuesto,      
			     IVA = SUM (IVACargosPagado),
			     IdProductoServicio = 1,
			     IdUnidadMedida = 1358,
			     IdSATtipoFactor = IIF(Impuesto.EsExento = 1, 3, 1)
		 FROM tFELfacturaGlobalIngresos Venta
		 INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Venta.IdImpuesto
		 WHERE Venta.IdPeriodo = @IdPeriodo AND CargosPagados > 0
		 GROUP BY Concepto, Impuesto.IdImpuesto, Impuesto.Descripcion, Impuesto.EsExento


		--ventas
		INSERT INTO dbo.tIMPcomprobantesFiscalesD(IdComprobante, Cantidad, Codigo, Descripcion, PrecioUnitario, Importe, IdImpuesto, IVA, IdProductoServicio, IdUnidadMedida, IdSATtipoFactor)
		SELECT @IdComprobante, Cantidad = 1,Codigo ='01010101',
			   Concepto = CONCAT(Venta.Concepto, ' ', Impuesto.Descripcion),
			   PrecioUnitario = SUM (VentaSubTotal),
			   Importe = SUM (VentaSubTotal),
			   Impuesto.IdImpuesto,      
			   IVA = SUM (VentaIVA),
			   IdProductoServicio = 1,
			   IdUnidadMedida = 1358,
			   IdSATtipoFactor = IIF(Impuesto.EsExento = 1, 3, 1)
		FROM tFELfacturaGlobalIngresos Venta
		INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Venta.IdImpuesto
		WHERE Venta.IdPeriodo = @IdPeriodo AND VentaSubTotal > 0
		GROUP BY Concepto, Impuesto.IdImpuesto,Impuesto.Descripcion, Impuesto.EsExento;


		--SE INSERTAN LOS DATOS ADICIONALES DEL COMPROBANTE
		INSERT INTO dbo.tFELestadoCuentaBancario(IdComprobante, IdPeriodo, IdEstatus)
		SELECT @IdComprobante, @IdPeriodo, 1

		--SE ACTUALIZA LA FORMA DE PAGO DEL CFDI
	
	 --   UPDATE Comprobante SET Comprobante.IdSATformaPago = FormaPago.IdSATformaPago, Comprobante.FormaPago = FormaPago.FormaPago
	 --   FROM dbo.tIMPcomprobantesFiscales		 Comprobante WITH(NOLOCK)
		--INNER JOIN dbo.tFELestadoCuentaBancario EstadoCuenta WITH(NOLOCK) ON EstadoCuenta.IdComprobante = Comprobante.IdComprobante
		--INNER JOIN dbo.fCFDIestadoCuentaBancario(@IdSocio, @IdCuenta, @IdPeriodo) CFDI ON CFDI.IdPeriodo = EstadoCuenta.IdPeriodo AND CFDI.IdCuenta = EstadoCuenta.IdCuenta AND CFDI.IdSocio = EstadoCuenta.IdSocio
		--INNER JOIN dbo.tSDOtransaccionesD TransaccionD WITH(NOLOCK) ON TransaccionD.IdOperacion = CFDI.IdOperacion
		--INNER JOIN dbo.tCATmetodosPago		MetodoPago WITH(NOLOCK) ON MetodoPago.IdMetodoPago = TransaccionD.IdMetodoPago
		--INNER JOIN dbo.tSATformasPago		 FormaPago WITH(NOLOCK) ON FormaPago.IdSATformaPago = MetodoPago.IdSatFormaPago
	
		-- SE INSERTAN LOS IMPUESTOS DEL COMPROBANTE
		EXECUTE dbo.pImpuestosComprobante @IdComprobante = @IdComprobante		
	END



	SELECT * FROM dbo.tSATformasPago