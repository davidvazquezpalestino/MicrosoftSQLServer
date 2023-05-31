BEGIN TRAN

DECLARE @IdCuenta AS INT = 1378374;
/*SE ACTUALIZAN CAMPOS EN LA TABLA tSDOtransaccionesFinancieras*/
UPDATE Transaccion
SET Transaccion.SaldoCapitalAnterior = SaldoTransaccional.SaldoCapitalAnterior,
    Transaccion.SaldoCapital = SaldoTransaccional.SaldoCapital,
    Transaccion.SaldoAnterior = SaldoTransaccional.SaldoAnterior,
    Transaccion.CambioNeto = SaldoTransaccional.CambioNeto
FROM dbo.tSDOtransaccionesFinancieras Transaccion WITH( NOLOCK )
INNER JOIN( SELECT IdSaldoDestino,
                   IdTransaccion,
                   SaldoCapitalAnterior = SUM (CapitalGenerado - CapitalPagado) OVER ( PARTITION BY IdCuenta
                                                                                       ORDER BY Fecha,
                                                                                                IdTransaccion ) - ( CapitalGenerado - CapitalPagado ),
                   SaldoCapital = SUM (CapitalGenerado - CapitalPagado - ISNULL(CapitalPagadoVencido,0)) OVER ( PARTITION BY IdCuenta
                                                                               ORDER BY Fecha,
                                                                                        IdTransaccion ),
                   SaldoAnterior = SUM (CapitalGenerado - CapitalPagado - ISNULL(CapitalPagadoVencido,0) + InteresOrdinarioDevengado - InteresOrdinarioPagado + InteresAcapitalizar - InteresCapitalizado - InteresRetirado) OVER ( PARTITION BY IdCuenta
                                                                                                                                                                                                   ORDER BY Fecha,
                                                                                                                                                                                                            IdTransaccion )
                                   - ( CapitalGenerado - CapitalPagado + InteresOrdinarioDevengado - InteresOrdinarioPagado + InteresAcapitalizar - InteresCapitalizado - InteresRetirado ),
                   CambioNeto = CapitalGenerado - CapitalPagado -ISNULL(CapitalPagadoVencido,0) + InteresOrdinarioDevengado - InteresOrdinarioPagado + InteresAcapitalizar - InteresCapitalizado - InteresRetirado,
                   Saldo = SUM (CapitalGenerado - CapitalPagado -ISNULL(CapitalPagadoVencido,0) + InteresOrdinarioDevengado - InteresOrdinarioPagado + InteresAcapitalizar - InteresCapitalizado - InteresRetirado) OVER ( PARTITION BY IdCuenta
                                                                                                                                                                                           ORDER BY Fecha,
                                                                                                                                                                                                    IdTransaccion )
            FROM dbo.vSDOtransaccionesFinancierasISNULL
            WHERE IdCuenta = @IdCuenta AND IdEstatus = 1 AND IdCuenta <> 0 ) AS SaldoTransaccional ON Transaccion.IdTransaccion = SaldoTransaccional.IdTransaccion
WHERE Transaccion.IdCuenta = @IdCuenta;

/*SE ACTUALIZA LA TABLA DE tSDOsaldos*/
UPDATE Saldo
SET Saldo.CapitalGenerado = SaldoTransaccional.CapitalGenerado,
    Saldo.CapitalPagado = SaldoTransaccional.CapitalPagado,
    Saldo.InteresOrdinarioDevengado = SaldoTransaccional.InteresOrdinarioDevengado,
    Saldo.InteresOrdinarioPagado = SaldoTransaccional.InteresOrdinarioPagado,
    Saldo.InteresPendienteCapitalizar = SaldoTransaccional.InterespendienteCapitalizar,
    Saldo.MontoBloqueado = SaldoTransaccional.MontoBloqueado
FROM dbo.tSDOsaldos Saldo WITH( NOLOCK )
LEFT JOIN( SELECT CapitalGenerado = SUM (CapitalGenerado),
                  CapitalPagado = SUM (CapitalPagado) + SUM(ISNULL(CapitalPagadoVencido,0)),
                  InteresOrdinarioDevengado = SUM (InteresOrdinarioDevengado),
                  InteresOrdinarioPagado = SUM (InteresOrdinarioPagado),
                  InterespendienteCapitalizar = SUM (InteresAcapitalizar - InteresCapitalizado - InteresRetirado),
                  MontoBloqueado = SUM (MontoBloqueado - MontoDesbloqueado),
                  IdSaldoDestino
           FROM dbo.vSDOtransaccionesFinancierasISNULL
           WHERE IdCuenta = @IdCuenta AND IdEstatus = 1 AND IdCuenta <> 0
           GROUP BY IdSaldoDestino ) AS SaldoTransaccional ON Saldo.IdSaldo = SaldoTransaccional.IdSaldoDestino
WHERE Saldo.IdCuenta = @IdCuenta;

/*POR ULTIMO SE ACTIUALIZA LA TABLA tAYCcuentas*/
UPDATE Cuenta
SET Cuenta.SaldoCapital = s.Capital
FROM dbo.tAYCcuentas Cuenta
JOIN dbo.fAYCsaldo (@IdCuenta) s ON s.IdCuenta = Cuenta.IdCuenta
WHERE Cuenta.IdCuenta = @IdCuenta;


