
	USE intelixDEV
	go


    
	DECLARE @IdOperacion INT = ( SELECT IdOperacion FROM dbo.tgrloperaciones WHERE IdTipoOperacion = 10 AND Folio = 58025 );
	
	DROP TABLE IF EXISTS #Empleados;
	CREATE TABLE #Empleados (
	[IdPersona] INT,
	[IdEmpleado] INT,
	[RegistroPatronal] VARCHAR(20),
	[NumEmpleado] VARCHAR(20),
	[CURP] VARCHAR(30),
	[TipoRegimen] VARCHAR(20),
	[NumeroSeguridadSocial] VARCHAR(30),
	[NumDiasPagados] INT,
	[Departamento] VARCHAR(30),
	[CLABE] VARCHAR(20),
	[Banco] VARCHAR(3),
	[FechaInicioRelLaboral] DATE,
	[Antiguedad] INT,
	[Puesto] VARCHAR(30),
	[TipoContrato] VARCHAR(20),
	[TipoJornada] VARCHAR(20),
	[PeriodicidadPago] VARCHAR(20),
	[SalarioBaseCotApor] DECIMAL(18, 2),
	[RiesgoPuesto] VARCHAR(20),
	[SalarioDiario] DECIMAL(18, 2),
	[SDI] DECIMAL(18, 2),
	[TipoNomina] VARCHAR(1),
	[ClaveEntidadFederativa] VARCHAR(3),
	[Sindicalizado] VARCHAR(2));
	
	INSERT INTO #Empleados(IdPersona, IdEmpleado, RegistroPatronal, NumEmpleado, CURP, TipoRegimen, NumeroSeguridadSocial, NumDiasPagados, Departamento, CLABE, Banco, FechaInicioRelLaboral, Antiguedad, Puesto, TipoContrato, TipoJornada, PeriodicidadPago, SalarioBaseCotApor, RiesgoPuesto, SalarioDiario, SDI, TipoNomina, ClaveEntidadFederativa, Sindicalizado)
	SELECT PersonaFisica.IdPersona, emp.IdEmpleado, [RegistroPatronal] = FacturaEmpleado.RegistroPatronal, [NumEmpleado] = emp.Codigo, [CURP] = PersonaFisica.CURP, [TipoRegimen] = TipoRegimen.Codigo, [NumeroSeguridadSocial] = FacturaEmpleado.NumSeguridadSocial, [NumDiasPagados] = 1, [Departamento] = Departamento.Descripcion, [CLABE] = FacturaEmpleado.CLABE, [Banco] = Banco.Clave, [FechaInicioRelLaboral] = emp.FechaIngreso, [Antiguedad] = DATEDIFF(WEEKDAY, FacturaEmpleado.FechaInicioRelLaboral, CURRENT_TIMESTAMP), [Puesto] = Puesto.Descripcion, [TipoContrato] = TipoContrato.Codigo, [TipoJornada] = TipoJornada.Codigo, [PeriodicidadPago] = TipoPeriodicidad.Codigo, [SalarioBaseCotApor] = FacturaEmpleado.SalarioBaseCotApor, [RiesgoPuesto] = TipoRiesgo.Codigo, [SalarioDiario] = FacturaEmpleado.SalarioDiario, SDI = FacturaEmpleado.SalarioDiarioIntegrado, [TipoNomina] = 'E', [ClaveEntidadFederativa] = Estado.ClaveEntidadFederativa, FacturaEmpleado.[Sindicalizado]
	FROM dbo.tPERempleados emp WITH(NOLOCK)
	INNER JOIN dbo.tCTLestatusActual Estatus WITH(NOLOCK)ON Estatus.IdEstatusActual = emp.IdEstatusActual
	INNER JOIN dbo.tGRLpersonasFisicas PersonaFisica WITH(NOLOCK)ON PersonaFisica.IdPersonaFisica = emp.IdPersonaFisica
	INNER JOIN dbo.tFELempleados FacturaEmpleado WITH(NOLOCK)ON FacturaEmpleado.IdRFC = PersonaFisica.IdPersonaFisica
	INNER JOIN dbo.tCTLestados Estado WITH(NOLOCK)ON Estado.IdEstado = FacturaEmpleado.IdEstadoPrestaServicio
	INNER JOIN dbo.tCTLtiposD TipoRegimen WITH(NOLOCK)ON TipoRegimen.IdTipoD = FacturaEmpleado.IdTipoDregimen
	INNER JOIN dbo.tSATbancos Banco WITH(NOLOCK)ON Banco.IdBanco = FacturaEmpleado.IdBancoSAT
	INNER JOIN dbo.tPERpuestos Puesto WITH(NOLOCK)ON Puesto.IdPuesto = FacturaEmpleado.IdPuesto
	INNER JOIN dbo.tPERdepartamentos Departamento WITH(NOLOCK)ON Departamento.IdDepartamento = Puesto.IdDepartamento
	INNER JOIN dbo.tCTLtiposD TipoContrato WITH(NOLOCK)ON TipoContrato.IdTipoD = FacturaEmpleado.IdTipoDcontrato
	INNER JOIN dbo.tCTLtiposD TipoJornada WITH(NOLOCK)ON TipoJornada.IdTipoD = FacturaEmpleado.IdTipoDjornada
	INNER JOIN dbo.tCTLtiposD TipoPeriodicidad WITH(NOLOCK)ON TipoPeriodicidad.IdTipoD = FacturaEmpleado.IdTipoDperiodicidad
	INNER JOIN dbo.tCTLtiposD TipoRiesgo WITH(NOLOCK)ON TipoRiesgo.IdTipoD = FacturaEmpleado.IdTipoDriesgoSAT
	WHERE Estatus.IdEstatus = 1;
	
	DROP TABLE IF EXISTS #Emisores;
	CREATE TABLE #Emisores 
	(
	IdEmpresa INT,
	IdEmisor INT,
	IdEmisorProveedor INT,
	EmisorRFC VARCHAR(30),
	EmisorNombre VARCHAR(250),
	CodigoPostal VARCHAR(5),
	RegimenFiscal VARCHAR(3),
	IdSATregimenFiscal INT
	);

	INSERT INTO #Emisores(IdEmpresa, IdEmisor, IdEmisorProveedor, EmisorRFC, EmisorNombre, CodigoPostal, RegimenFiscal, IdSATregimenFiscal)
	SELECT Empresa.IdEmpresa, Persona.IdPersona, PersonaEmisor.IdEmisorProveedor, EmisorRFC = Persona.RFC, EmisorNombre = Persona.Nombre, Domicilio.CodigoPostal, RegimenFiscal.RegimenFiscal, RegimenFiscal.IdSATregimenFiscal
	FROM dbo.tGRLpersonas Persona
	INNER JOIN dbo.tCTLempresas Empresa ON Empresa.IdEmpresa = Persona.IdEmpresa AND Empresa.IdPersona = Persona.IdPersona
	INNER JOIN dbo.tSCSemisoresProveedores PersonaEmisor ON PersonaEmisor.IdPersona = Persona.IdPersona
	INNER JOIN dbo.tSATregimenFiscal RegimenFiscal WITH(NOLOCK)ON RegimenFiscal.IdSATregimenFiscal = Empresa.IdRegimenFiscal
	INNER JOIN dbo.tCATdomicilios Domicilio ON Persona.IdRelDomicilios = Domicilio.IdRel
	INNER JOIN dbo.tCTLestatusActual Estatus ON Estatus.IdEstatusActual = Domicilio.IdEstatusActual
	WHERE Persona.IdPersona = 1 AND Estatus.IdEstatus = 1;
	
	DROP TABLE IF EXISTS #Receptores;
	CREATE TABLE #Receptores (
	IdEmpresa INT,
	IdReceptor INT,
	IdPersona INT,
	IdOperacion INT
	);
		
	INSERT INTO #Receptores(IdEmpresa, IdReceptor, IdPersona, IdOperacion)
	
	SELECT IdEmpresa = 1, IdReceptor = saldo.IdPersona, saldo.IdPersona, @IdOperacion
	FROM dbo.tSDOtransacciones Transaccion
	INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion = Transaccion.IdOperacion
	INNER JOIN dbo.tSDOsaldos saldo ON saldo.IdSaldo = Transaccion.IdSaldoDestino	
	INNER JOIN dbo.tGRLpersonas PersonaSaldo ON PersonaSaldo.IdPersona = saldo.IdPersona	
	WHERE  Transaccion.IdAuxiliar IN (-26, -27) AND Transaccion.SubTotalGenerado > 0 AND Operacion.IdOperacion = @IdOperacion ;
	
	DROP TABLE IF EXISTS #Comprobante
	CREATE TABLE #Comprobante ( 
		IdOperacion INT,
		TipoComprobante VARCHAR(1),
		IdTipoDComprobante INT,
		IdAuxiliar INT,
		Serie VARCHAR(1),
		Folio INT,
		Fecha DATE,
		FechaHora DATETIME,
		Importe DECIMAL(23, 8),
		IdDivisa INT,
		DivisaCodigo VARCHAR(5),
		TipoCambio DECIMAL(18, 8),
		Nombre VARCHAR(250),
		RFC VARCHAR(30),
		IdEstatus INT,
		MetodoPago VARCHAR(3),
		FormaPago VARCHAR(2),
		Mail VARCHAR(512),
		IdUsoCfdi INT )

	INSERT INTO #Comprobante(IdOperacion, TipoComprobante, IdTipoDComprobante, IdAuxiliar, Serie, Folio, Fecha, FechaHora, Importe, IdDivisa, DivisaCodigo, TipoCambio, Nombre, RFC, IdEstatus, MetodoPago, FormaPago, Mail, IdUsoCfdi)
	SELECT @IdOperacion, TipoComprobante = 'N', IdTipoDComprobante = 902, Transaccion.IdAuxiliar, Serie = '', Folio = 0, Operacion.Fecha, FechaHora = Operacion.Fecha, Transaccion.SubTotalGenerado, Divisa.IdDivisa, Divisa.Codigo, Operacion.FactorDivisa, PersonaSaldo.Nombre, PersonaSaldo.RFC, Operacion.IdEstatus, MetodoPago = 'PUE', FormaPago = '99', Emails.Emails, IdUsoCfdi = 22	
	FROM dbo.tSDOtransacciones Transaccion
	INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion = Transaccion.IdOperacion
	INNER JOIN dbo.tSDOsaldos saldo ON saldo.IdSaldo = Transaccion.IdSaldoDestino
	INNER JOIN dbo.tCTLdivisas Divisa ON Divisa.IdDivisa = saldo.IdDivisa
	INNER JOIN dbo.tGRLpersonas PersonaSaldo ON PersonaSaldo.IdPersona = saldo.IdPersona
	LEFT JOIN dbo.vCATEmailsAgrupados Emails ON PersonaSaldo.IdRelEmails = Emails.IdRel
	WHERE Operacion.IdOperacion = @IdOperacion AND Transaccion.IdAuxiliar IN (-26, -27) AND Transaccion.SubTotalGenerado > 0;

	


	SELECT * FROM #Comprobante


	--INSERT INTO dbo.tIMPcomprobantesFiscales(IdEmisor, IdReceptor, TipoComprobante, IdTipoDComprobante, Serie, Folio, Fecha, FechaHora, Importe, Subtotal, IdDivisa, TipoCambio, NombreEmisor, RFCEmisor, NombreReceptor, RFCReceptor, IdEstatus, MetodoPago, FormaPago, Email, RegimenFiscal, CodigoDivisa, IdPersona, IdEmisorProveedor, Total, Version, IdUsoCfdi, IdSATformaPago, IdSATmetodoPago, CodigoPostalLugarExpedicion, IdSATregimenFiscal, IdComplemento, IdOperacion, IdAuxiliar)
	--SELECT Emisor.IdEmisor, Receptor.IdReceptor, Receptor.TipoComprobante, Receptor.IdTipoDComprobante, Receptor.Serie, Receptor.Folio, Receptor.Fecha, Receptor.FechaHora, Receptor.Importe, Receptor.Importe, Receptor.IdDivisa, Receptor.TipoCambio, Emisor.EmisorNombre, Emisor.EmisorRFC, Receptor.Nombre, Receptor.RFC, IdEstatus = 1, Receptor.MetodoPago, Receptor.FormaPago, Receptor.Mail, Emisor.RegimenFiscal, Receptor.DivisaCodigo, Receptor.IdPersona, Emisor.IdEmisorProveedor, Receptor.Importe, Version = '3.3', Receptor.IdUsoCfdi, IdSATformaPago = 20, IdSATmetodoPago = 1, Emisor.CodigoPostal, Emisor.IdSATregimenFiscal, IdComplemento = 13, @IdOperacion, Receptor.IdAuxiliar
	--FROM #Emisores   Emisor WITH(NOLOCK)  ON Emisor.IdEmpresa
	--INNER JOIN #Receptores Receptor WITH(NOLOCK)ON Receptor.IdEmpresa = Emisor.IdEmpresa
	--INNER JOIN #Comprobante Comprobante WITH(NOLOCK) ON Comprobante.IdOperacion = Receptor.IdOperacion
	--WHERE NOT EXISTS (SELECT 1
	--				  FROM dbo.tIMPcomprobantesFiscales comprobante
	--				  WHERE comprobante.IdOperacion = @IdOperacion );

	
	--INSERT INTO dbo.tIMPcomprobantesFiscalesD(IdComprobante, Partida, Cantidad, Codigo, Descripcion, PrecioUnitario, Importe, IdProductoServicio, IdUnidadMedida, IdSATtipoFactor)
	--SELECT comprobante.IdComprobante, Partida = 1, Cantidad = 1, Codigo = 'Servicio', Descripcion = 'Pago de nómina', comprobante.Importe, comprobante.Importe, IdProductoServicio = 51541, IdUnidadMedida = 1358, IdSATtipoFactor = 1
	--FROM dbo.tIMPcomprobantesFiscales comprobante
	--INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion = comprobante.IdOperacion
	--WHERE Operacion.IdOperacion = @IdOperacion AND comprobante.TipoComprobante = 'N' 
	--AND NOT EXISTS (SELECT 1
	--				FROM dbo.tIMPcomprobantesFiscalesD Detalle
	--				WHERE Detalle.IdComprobante = comprobante.IdComprobante);
	
	--INSERT INTO dbo.tNOMnominas(Folio, Fecha, Concepto, IdPeriodo, IdDivisa, FactorDivisa, FechaPago, FechaInicioPago, FechaFinPago, IdSucursal, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdTipoDDominio, IdSesion, IdOperacion)
	--SELECT Folio, Fecha, 'NOMINA', IdPeriodo, IdDivisa, FactorDivisa, Fecha, Fecha, Fecha, IdSucursal, IdEstatus, IdUsuarioAlta, Fecha, IdUsuarioCambio, UltimoCambio, IdTipoDdominio = 1467, IdSesion, IdOperacion
	--FROM dbo.tGRLoperaciones
	--WHERE IdOperacion = @IdOperacion AND NOT EXISTS (SELECT 1 FROM dbo.tNOMnominas WHERE IdOperacion = @IdOperacion);
	
	--INSERT INTO dbo.tFELcomplementosNomina(IdComprobante, IdNomina, Version, RegistroPatronal, NumEmpleado, CURP, TipoRegimen, NumSeguridadSocial, FechaPago, FechaInicialPago, FechaFinalPago, NumDiasPagados, Departamento, CLABE, Banco, FechaInicioRelLaboral, Antiguedad, Puesto, TipoContrato, TipoJornada, PeriodicidadPago, SalarioBaseCotApor, RiesgoPuesto, SalarioDiario, SalarioDiarioIntegrado, TipoNomina, TotalOtroPago, ClaveEntidadFederativa, Sindicalizado, IdEmpleado)
	--SELECT IdComprobante, Nomina.IdNomina, Version = '1.2', Empleado.RegistroPatronal, Empleado.NumEmpleado, Empleado.CURP, Empleado.TipoRegimen, Empleado.NumeroSeguridadSocial, Nomina.FechaPago, Nomina.FechaInicioPago, Nomina.FechaFinPago, Empleado.NumDiasPagados, Empleado.Departamento, Empleado.Puesto, Empleado.Banco, Empleado.FechaInicioRelLaboral, Empleado.Antiguedad, Empleado.Puesto, Empleado.TipoContrato, Empleado.TipoJornada, Empleado.PeriodicidadPago, Empleado.SalarioBaseCotApor, Empleado.RiesgoPuesto, Empleado.SalarioDiario, Empleado.SDI, Empleado.TipoNomina, Comprobante.Total, Empleado.ClaveEntidadFederativa, Empleado.Sindicalizado, Empleado.IdEmpleado
	--FROM dbo.tIMPcomprobantesFiscales Comprobante WITH(NOLOCK)
	--INNER JOIN dbo.tNOMnominas Nomina WITH(NOLOCK)ON Nomina.IdOperacion = Comprobante.IdOperacion
	--INNER JOIN #Empleados Empleado WITH(NOLOCK)ON Empleado.IdPersona = Comprobante.IdPersona
	--WHERE Comprobante.IdOperacion = @IdOperacion AND NOT EXISTS (SELECT 1 FROM dbo.tFELcomplementosNomina complemento
	--															 WHERE complemento.IdComprobante = Comprobante.IdComprobante AND Comprobante.IdComprobante = 1);
	
	--INSERT INTO dbo.tFELotrosPagos(IdComplementoNomina, TipoOtroPago, Clave, Concepto, Importe, IdEmpleado)	
	--SELECT IdComplementoNomina, OtroPago.Codigo, OtroPago.Codigo, OtroPago.Descripcion, Comprobante.Importe, Complemento.IdEmpleado
	--FROM dbo.tIMPcomprobantesFiscales Comprobante
	--INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdComprobante = Comprobante.IdComprobante
	--INNER JOIN dbo.tCATotrosPagos OtroPago ON OtroPago.IdAuxiliar = Comprobante.IdAuxiliar
	--WHERE Comprobante.IdOperacion = @IdOperacion
	--AND NOT EXISTS (SELECT 1 FROM dbo.tFELotrosPagos pago WHERE Complemento.IdComplementoNomina = pago.IdComplementoNomina)
	

