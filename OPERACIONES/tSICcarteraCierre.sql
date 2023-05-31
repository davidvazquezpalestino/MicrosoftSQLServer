

DECLARE @IdPeriodo INT = dbo.fGETidPeriodo('20180331');
DECLARE @UsaEstimacionCalculada BIT = 0

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tSICcarteraCierre')
BEGIN
	DROP TABLE tSICcarteraCierre
END

SELECT  -- Datos Generales
		Cuenta.IdCuenta,
		Socio.IdSocio,
		Socio.Codigo as Socio,
		NombreSocio = Persona.Nombre,
		Cuenta = Cuenta.Codigo,
		Sucursal = Sucursal.Codigo,
		SucursalNombre = Sucursal.Descripcion,
		Producto = ProductoFinanciero.Descripcion,
		FechaActivacion = Cuenta.FechaActivacion,
		Plazo = ROUND(DATEDIFF(d,Cuenta.FechaActivacion,Cuenta.Vencimiento)/30.0,0),
		DiasPlazo = Cuenta.Dias,
		NumeroParcialidades = Cuenta.NumeroParcialidades,
		Cuenta.Vencimiento,
		Finalidad = Finalidad.Descripcion,		
		MontoEntregado = Cuenta.MontoEntregado,
		TasaInteresOrdinario = Cuenta.InteresOrdinarioAnual*100,		
		-- Datos Estadisticos
		MontoUltimoPagoCapital = Historial.MontoUltimoPagoCapital,
        MontoUltimoPagoInteres = Historial.MontoUltimoPagoInteres,
		FechaUltimoPagoCapital = Historial.FechaUltimoPagoCapital,
		FechaUltimoPagoInteres = Historial.FechaUltimoPagoInteres,
		DiasTranscurridos = 0,		
		-- Vigente
		CapitalVigente = IIF(Historial.IdEstatusCartera = 28,Historial.SaldoCapital, 0),
		InteresOrdinarioVigente = IIF(Historial.IdEstatusCartera = 28,Historial.SaldoInteresOrdinario, 0),
		InteresMoratorioVigente = IIF(Historial.IdEstatusCartera = 28,Historial.SaldoInteresMoratorio, 0),
		-- Vencido
		CapitalVencido  =  IIF(Historial.IdEstatusCartera = 29,Historial.SaldoCapital, 0),
		InteresOrdinarioVencido  =  IIF(Historial.IdEstatusCartera = 29, Historial.SaldoInteresOrdinario, 0),
		InteresMoratorioVencido = IIF(Historial.IdEstatusCartera = 29,Historial.SaldoInteresMoratorio, 0),
		-- Cuentas de Orden
		InteresMoratorioCuentasOrden  =  Historial.MoratoriosDevengadosFB,		
		InteresOrdinarioCuentasOrden  =  Historial.OrdinariosDevengadosFB,		
		-- Totales
		CapitalTotal = Historial.SaldoCapital,
		InteresOrdinarioTotal = Historial.SaldoInteresOrdinario,		
		InteresMoratorioTotal = Historial.SaldoInteresMoratorio,
		TotalCarteraVigente  =  IIF(Historial.IdEstatusCartera = 28,Historial.SaldoCapital+Historial.SaldoInteresOrdinario+Historial.SaldoInteresMoratorio, 0),
		TotalCarteraVencida  =  IIF(Historial.IdEstatusCartera = 29,Historial.SaldoCapital+Historial.SaldoInteresOrdinario+Historial.SaldoInteresMoratorio, 0),
		TotalCartera  =  Historial.SaldoCapital+Historial.SaldoInteresOrdinario+Historial.SaldoInteresMoratorio,
		EnCarteraVencida  =  CASE WHEN Historial.IdEstatusCartera = 29 THEN 'Si' ELSE 'No' END,
		CapitalAtrasado = ISNULL(Cartera.CapitalAtrasado,0),
		ParcialidadesAtrasadas = ISNULL(Cartera.ParcialidadesCapitalAtrasadas,0),
		DiasMoraCapital = IIF(Historial.IdEstatus! = 1,0,ISNULL(Cartera.DiasMoraCapital,0)),
		DiasMoraInteres = IIF(Historial.IdEstatus! = 1,0,ISNULL(Cartera.DiasMoraInteres,0)),
		DiasMora = Historial.DiasMora,	
		MontoSolicitado  =  Cuenta.MontoSolicitado,				
		RenovadaRestructurada  =  CASE WHEN Cuenta.IdCuentaRenovada+Cuenta.IdCuentaRestructurada > 0 THEN 'Si' ELSE 'No' END,	
		InteresOrdinarioMes  =  Historial.InteresesOrdinarioDevengado,
		Unico  = CASE WHEN Cuenta.idTipoDparcialidad  = 719 THEN 'Si' ELSE 'No' END,
		PagoFijo  = CASE WHEN Cuenta.idTipoDparcialidad  = 415 THEN 'Si' ELSE 'No' END,
		Interesinsolutos  = 'Si',
		DiaFijo  = CASE WHEN Cuenta.VenceMismoDia  = 1 THEN 'Si' ELSE 'No' END,
		CondicionPago  = ModalidadPago.DescripcionModalidadPago,		
		PagosSostenidos = Cuenta.PagosSostenidos,
		ProximoAbono  = ISNULL(Cartera.ProximoVencimiento,'1900-01-01'),
		MontoOtorgadoMes =  CASE WHEN month(Cuenta.FechaActivacion) = month(Periodo.Fin) AND year(Cuenta.FechaActivacion) = year(Periodo.Fin) THEN Cuenta.MontoEntregado ELSE 0 END,
		CapitalExigible = ISNULL(Cartera.CapitalExigible,0),		
		Estatus = EstatusHistorial.Descripcion,
		EstaEmproblemada  =  IIF(Historial.EstaEmproblemada  =  1, 'Si', 'No' ),
		TipoCartera  =  Historial.TipoCartera,
		TipoDePrestamo = Clasificacion.Descripcion,
		TablaEstimacion = TablaEstimacion.Descripcion,				
		MontoGarantia = Historial.ParteCubierta,
		GarantiaHipotecaria = Historial.ValorGarantiaHipotecaria,
		GarantiaPrendaria = ISNULL(Historial.GarantiaPrendaria,0),
		MontoBloqueado = Historial.MontoBloqueado,	
		ParteCubierta  =  Estimacion.ParteCubierta,
		ParteExpuesta  =  Estimacion.ParteExpuesta,
		PorcentajeEstimacionParteCubierta  = IIF(@UsaEstimacionCalculada = 1, Estimacion.PorcentajeParteCubierta*100, Historial.PorcentajeEstimacionParteCubierta),
		---se establece el porcentaje de la parte expuesta por dispocicion de la CNBV este cambio es temporal,
		--- ya que se requiere de cambios para determinar cuando una cuenta es ordenada a un porcentaje de estimacion segun la comision nacional bancaria
		PorcentajeEstimacionParteExpuesta  = IIF(@UsaEstimacionCalculada = 1, Estimacion.PorcentajeParteExpuesta*100, Historial.PorcentajeEstimacionParteExpuesta),
		PorcentajeRegimenTransitorio  = 100,
		EstimacionParteCubierta  = IIF(@UsaEstimacionCalculada = 1, round(Estimacion.ParteCubierta*Estimacion.PorcentajeParteCubierta,2), Historial.EstimacionParteCubierta),
		EstimacionParteExpuesta  = IIF(@UsaEstimacionCalculada = 1, round(Estimacion.ParteExpuesta*Estimacion.PorcentajeParteExpuesta,2), Historial.EstimacionParteExpuesta),
		Estimacion = IIF(@UsaEstimacionCalculada = 1, round(Estimacion.ParteCubierta*Estimacion.PorcentajeParteCubierta,2), Historial.EstimacionParteCubierta)
					  + IIF(@UsaEstimacionCalculada = 1, round(Estimacion.ParteExpuesta*Estimacion.PorcentajeParteExpuesta,2), Historial.EstimacionParteExpuesta),
		EstimacionAdicional  = IIF(@UsaEstimacionCalculada = 1, IIF(Estimacion.IdEstatusCartera = 29, Estimacion.SaldoInteresOrdinario+Estimacion.SaldoInteresMoratorio,0), Historial.EstimacionAdicional),		
		EstimacionCNBV = CASE WHEN @UsaEstimacionCalculada = 1 
								THEN IIF(Estimacion.PorcentajeEstimacionEspecialParteCubierta = 0, 0, Estimacion.PorcentajeEstimacionEspecialParteCubierta*Estimacion.ParteCubierta-round(Estimacion.ParteCubierta*Estimacion.PorcentajeParteCubierta,2))
									+IIF(Estimacion.PorcentajeEstimacionEspecialParteExpuesta = 0, 0, Estimacion.PorcentajeEstimacionEspecialParteExpuesta*Estimacion.ParteExpuesta-round(Estimacion.ParteExpuesta*Estimacion.PorcentajeParteExpuesta,2))								
								ELSE Historial.EstimacionCNBV
						  END,
		EstimacionRiesgosOperativos  =  0,
		EstimacionAnterior = Estimacion.EstimacionAnterior,
		EstimacionAdicionalAnterior = Estimacion.EstimacionAdicionalAnterior,
		EstimacionCNBVAnterior  =  Historial.EstimacionCNBVanterior,
		EstimacionRiesgosOperativosAnterior  =  Historial.EstimacionRiesgosOperativosAnterior,
		EstimacionAjuste  =  IIF(@UsaEstimacionCalculada = 1, round(Estimacion.ParteCubierta*Estimacion.PorcentajeParteCubierta,2)+round(Estimacion.ParteExpuesta*Estimacion.PorcentajeParteExpuesta,2)-Estimacion.EstimacionAnterior, Historial.Estimacion-Historial.EstimacionAnterior),
		EstimacionAdicionalAjuste  =  IIF(@UsaEstimacionCalculada = 1, IIF(Estimacion.IdEstatusCartera = 29, Estimacion.SaldoInteresOrdinario+Estimacion.SaldoInteresMoratorio,0)-Estimacion.EstimacionAdicionalAnterior, Historial.EstimacionAdicional-Historial.EstimacionAdicionalAnterior),
		EstimacionCNBVAjuste = CASE	WHEN @UsaEstimacionCalculada = 1 
									THEN IIF(Estimacion.PorcentajeEstimacionEspecialParteCubierta = 0, 0, Estimacion.PorcentajeEstimacionEspecialParteCubierta*Estimacion.ParteCubierta-round(Estimacion.ParteCubierta*Estimacion.PorcentajeParteCubierta,2))
										+IIF(Estimacion.PorcentajeEstimacionEspecialParteExpuesta = 0, 0, Estimacion.PorcentajeEstimacionEspecialParteExpuesta*Estimacion.ParteExpuesta-round(Estimacion.ParteExpuesta*Estimacion.PorcentajeParteExpuesta,2))								
									ELSE Historial.EstimacionCNBV
							   END - ISNULL(Historial.EstimacionCNBVanterior,0),
		EstimacionRiesgosOperativosAjuste  =  0,		
		Estimacion.Banda, 
		-- Datos de Control
		Estimacion.BaseCalificacion,
		Estimacion.ExistePorcentajeParteExpuesta,
		Estimacion.ExistePorcentajeParteCubierta,
		Estimacion.ExisteInformacionPeriodo,		
		Historial.IdPeriodo, 
		Historial.IdEstatusCartera, 
		Historial.GarantiaLiquida,
		Division  =  Division.Descripcion
INTO tSICcarteraCierre
FROM tSDOhistorialDeudoras Historial WITH(NOLOCK)
INNER JOIN tCTLperiodos Periodo		 WITH(NOLOCK) on Historial.IdPeriodo = Periodo.IdPeriodo AND Periodo.IdPeriodo = @IdPeriodo
INNER JOIN fAYCestimarCuenta(0, (SELECT peri.FIN FROM tCTLperiodos peri WITH(NOLOCK) WHERE IdPeriodo = @IdPeriodo), @IdPeriodo) Estimacion on Historial.IdCuenta = Estimacion.IdCuenta
LEFT JOIN tAYCcarteraSistema Cartera	WITH(NOLOCK) on Historial.IdCuenta = Cartera.IdCuenta AND Cartera.FechaCartera = Periodo.Fin 
INNER JOIN tAYCcuentas Cuenta		WITH(NOLOCK) ON Historial.IdCuenta = Cuenta.IdCuenta
INNER JOIN tSCSsocios Socio			WITH(NOLOCK) ON Cuenta.IdSocio = Socio.IdSocio
INNER JOIN tCTLsucursales Sucursal		WITH(NOLOCK) ON Historial.IdSucursal = Sucursal.IdSucursal
INNER JOIN tAYCproductosFinancieros ProductoFinanciero WITH(NOLOCK) on Cuenta.IdProductoFinanciero = ProductoFinanciero.IdProductoFinanciero
INNER JOIN tCTLtiposD Clasificacion			WITH(NOLOCK) ON Cuenta.IdTipoDAICclasificacion = Clasificacion.IdTipoD
INNER JOIN tCTLtiposD TablaEstimacion		WITH(NOLOCK) ON Estimacion.IdTipoDtablaEstimacion = TablaEstimacion.IdtipoD
INNER JOIN tAYCfinalidades Finalidad	WITH(NOLOCK) ON Cuenta.IdFinalidad = Finalidad.IdFinalidad
INNER JOIN vSITmodalidadPago ModalidadPago 	WITH(NOLOCK) ON Historial.IdCuenta = ModalidadPago.IdCuenta
INNER JOIN tGRLpersonas Persona		WITH(NOLOCK) ON Socio.IdPersona = Persona.IdPersona
INNER JOIN tCTLestatus EstatusHistorial			WITH(NOLOCK) ON Historial.IdEstatus = EstatusHistorial.IdEstatus
INNER JOIN tCNTdivisiones Division WITH (nolock) ON Division.IdDivision  =  Cuenta.IdDivision
WHERE Periodo.IdPeriodo = @IdPeriodo
GO
