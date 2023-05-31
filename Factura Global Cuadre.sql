SELECT	Periodo = Periodo.Codigo, 
		Sucursal = CONCAT(Sucursal.Codigo, ' = ', Sucursal.Descripcion), 
		TipoOperacion = TipoOperacion.Descripcion, 
		OperacionPadre.Folio, 
		CuentaCodigo = Cuenta.Codigo, 
		CuentaDescripcion = Cuenta.Descripcion, 
		OperacionPadre.IdOperacion, 
		ProdServ.Descripcion, 
		Impuesto = Impuesto.Descripcion, 
		detalle.InteresOrdinario, 
		detalle.IVAInteresOrdinario, 
		detalle.InteresMoratorio, 
		detalle.IVAInteresMoratorio, 
		detalle.CargosPagados, 
		detalle.IVACargosPagado, 
		detalle.IdBienServicio, 
		SubtotalVenta = detalle.Subtotal, 
		detalle.IVAVenta, 
		CambioNeto = PolizaD.Abono - PolizaD.Cargo
FROM dbo.tFELfacturaGlobalIngresos detalle
INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion                = detalle.IdOperacion
INNER JOIN dbo.tGRLoperaciones OperacionPadre ON Operacion.IdOperacionPadre      = OperacionPadre.IdOperacion
INNER JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal                    = OperacionPadre.IdSucursal
INNER JOIN dbo.tCNTpolizasE PolizaE ON Operacion.IdPolizaE                       = PolizaE.IdPolizaE
INNER JOIN dbo.tCNTpolizasD PolizaD ON PolizaD.IdOperacion                       = Operacion.IdOperacion
INNER JOIN dbo.tGRLoperacionesD OperacionD ON OperacionD.IdOperacionD            = PolizaD.IdOperacionDOrigen
INNER JOIN dbo.tCNTcuentas Cuenta ON Cuenta.IdCuentaContable                     = PolizaD.IdCuentaContable
INNER JOIN dbo.tCNTasientosD asiento ON asiento.IdAsientoD                       = PolizaD.IdAsientoD
INNER JOIN dbo.tCTLtiposD TipoCuenta ON TipoCuenta.IdTipoD                       = Cuenta.IdTipoD
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion ON TipoOperacion.IdTipoOperacion = OperacionPadre.IdTipoOperacion
INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto                     = detalle.IdImpuesto
INNER JOIN dbo.tCTLperiodos Periodo ON Periodo.IdPeriodo                         = detalle.IdPeriodo
INNER JOIN dbo.tGRLbienesServicios ProdServ ON ProdServ.IdBienServicio           = CASE WHEN detalle.InteresOrdinario > 0 THEN -2019
                                                                                        WHEN detalle.InteresMoratorio > 0 THEN -2020
                                                                                        ELSE detalle.IdBienServicio
                                                                                   END
WHERE detalle.IdOperacionFactura = 2523655 AND ( Campo IN ( 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido', 'InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'CargosPagados', 'Subtotal' ) OR ( asiento.Campo = 'Subtotal' AND OperacionD.IdTipoSubOperacion = 17 )) AND asiento.IdTipoDDominio NOT IN ( 144, 398, 1575 );

