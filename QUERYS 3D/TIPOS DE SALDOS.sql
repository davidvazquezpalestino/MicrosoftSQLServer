SELECT [Región] = Region.Descripcion,
    Sucursal = Sucursal.Descripcion,
    Clase = Clase.Descripcion,
    Naturaleza = CASE Saldo.Naturaleza WHEN 1 THEN
                                            'DEUDORA'
                                       WHEN -1 THEN
                                            'ACREEDORA'
                                       ELSE 'NA'
                 END,
    [Tipo Operación] = TipoOperacion.Descripcion,
    [Operación Padre] = operacionPadre.OperacionPadre,
    [Operación] = operacionPadre.Operacion,
    Operacion.Fecha,
    YEAR = YEAR (Periodo.Inicio),
    [Período] = Periodo.Codigo,
    persona.IdPersona,
    [Deudor Acreedor] = persona.Nombre,
    Vendedor = PersonaVendedor.Nombre,
    [Tipo de Saldo] = Auxiliar.Descripcion,
    Transaccion.Concepto,
    Transaccion.Referencia,
    Generado = Transaccion.SubTotalGenerado,
    Pagado = Transaccion.SubTotalPagado,
    Saldo.Descripcion,
    RETENCION = IIF(Auxiliar.EsRetencionIVA = 1 OR Auxiliar.EsRetencionISR = 1, 'SI', 'NO'),
    Saldo.IdBienServicio
FROM dbo.tSDOsaldos AS Saldo WITH( NOLOCK )
INNER JOIN dbo.tCTLtiposD AS Clase WITH( NOLOCK )ON Clase.IdTipoD = Saldo.IdTipoDclase
INNER JOIN dbo.tSDOtransacciones AS Transaccion WITH( NOLOCK )ON Saldo.IdSaldo = Transaccion.IdSaldoDestino
INNER JOIN dbo.tGRLoperaciones AS Operacion WITH( NOLOCK )ON Transaccion.IdOperacion = Operacion.IdOperacion
INNER JOIN dbo.vGRLoperacionesPadrePoliza AS operacionPadre WITH( NOLOCK )ON Operacion.IdOperacion = operacionPadre.IdOperacion
INNER JOIN dbo.tCTLtiposOperacion AS TipoOperacion WITH( NOLOCK )ON Operacion.IdTipoOperacion = TipoOperacion.IdTipoOperacion
INNER JOIN dbo.tCTLperiodos AS Periodo WITH( NOLOCK )ON Operacion.IdPeriodo = Periodo.IdPeriodo
INNER JOIN dbo.tCTLsucursales AS Sucursal WITH( NOLOCK )ON Saldo.IdSucursal = Sucursal.IdSucursal
INNER JOIN dbo.vCTLusuarios AS Usuario WITH( NOLOCK )ON Operacion.IdUsuarioAlta = Usuario.IdUsuario
INNER JOIN dbo.tCNTauxiliares AS Auxiliar WITH( NOLOCK )ON Saldo.IdAuxiliar = Auxiliar.IdAuxiliar
INNER JOIN dbo.tGRLpersonas AS persona WITH( NOLOCK )ON persona.IdPersona = Operacion.IdPersona
INNER JOIN dbo.tCATlistasD AS Region WITH( NOLOCK )ON Region.IdListaD = Sucursal.IdListaDRegion
INNER JOIN dbo.tGRLpersonas PersonaVendedor ON PersonaVendedor.IdPersona = Operacion.IdPersonaVendedor
WHERE operacionPadre.IdOperacion <> 0 AND Transaccion.IdEstatus <> 18 ;
