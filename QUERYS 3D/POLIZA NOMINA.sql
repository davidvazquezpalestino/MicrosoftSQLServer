SELECT Periodo = Periodo.Codigo,
       Region = Region.Descripcion,
       Nomina.Folio,
       PolizaE.Concepto,
       PolizaD.Cargo,
       PolizaD.Abono,
       PercepcionDeduccion = PercepcionDeduccion.Descripcion,
       [Tipo de Saldo] = Auxiliar.Descripcion,
       EstructuraContable = EstructuraContable.Descripcion,
       [Perceciones Deducciones] = CASE WHEN PercepcionDeduccion.EsPercepcion = 1 THEN
                                             'PERCEPCIONES'
                                        WHEN PercepcionDeduccion.EsPercepcion = 0 THEN
                                             'DEDUCCIONES'
                                        ELSE 'NA'
                                   END,
       SucursalSueldo = SucursalPolizaD.Descripcion,
       Referencia = IIF(Empleado.Codigo = '', PolizaD.Referencia, Empleado.Codigo)

FROM dbo.tGRLoperaciones Operacion WITH( NOLOCK )
INNER JOIN dbo.tNOMnominas Nomina WITH( NOLOCK )ON Nomina.IdOperacion = Operacion.IdOperacion

INNER JOIN dbo.tCNTpolizasE PolizaE WITH( NOLOCK )ON PolizaE.IdPolizaE = Operacion.IdPolizaE
INNER JOIN dbo.tCNTpolizasD PolizaD WITH( NOLOCK )ON PolizaD.IdPolizaE = PolizaE.IdPolizaE

INNER JOIN dbo.tGRLbienesServicios PercepcionDeduccion WITH( NOLOCK )ON PercepcionDeduccion.IdBienServicio = PolizaD.IdBienServicio
INNER JOIN dbo.tCNTauxiliares Auxiliar WITH( NOLOCK )ON Auxiliar.IdAuxiliar = PolizaD.IdAuxiliar

INNER JOIN dbo.tGRLestructurasCatalogos Estructura WITH( NOLOCK )ON Estructura.IdEstructuraCatalogo = PercepcionDeduccion.IdEstructuraCatalogo
INNER JOIN dbo.tCNTestructurasContablesE EstructuraContable WITH( NOLOCK )ON EstructuraContable.IdEstructuraContableE = Estructura.IdEstructuraContableE

INNER JOIN dbo.tCTLsucursales Sucursal WITH( NOLOCK )ON Sucursal.IdSucursal = PolizaE.IdSucursal
INNER JOIN dbo.tCATlistasD Region WITH( NOLOCK )ON Region.IdListaD = Sucursal.IdListaDRegion

INNER JOIN dbo.tCTLperiodos Periodo WITH( NOLOCK )ON Periodo.IdPeriodo = PolizaE.IdPeriodo
INNER JOIN dbo.tCTLsucursales SucursalPolizaD WITH( NOLOCK )ON PolizaD.IdSucursal = SucursalPolizaD.IdSucursal

LEFT JOIN dbo.tSDOtransacciones Transaccion WITH( NOLOCK )ON PolizaD.IdTransaccion = Transaccion.IdTransaccion
LEFT JOIN dbo.tGRLoperaciones OperacionSueldo WITH( NOLOCK )ON Transaccion.IdOperacion = OperacionSueldo.IdOperacion
LEFT JOIN dbo.vPERempleados Empleado WITH( NOLOCK )ON OperacionSueldo.IdPersona = Empleado.IdPersona

WHERE Operacion.IdTipoOperacion = 18 AND Operacion.IdEstatus = 1 AND Nomina.Folio = 10
ORDER BY PercepcionDeduccion.IdBienServicio;
