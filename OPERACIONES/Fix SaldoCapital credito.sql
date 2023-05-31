DECLARE @IdCuenta AS INT = 1377874 ;

UPDATE TransaccionFinanciera
SET TransaccionFinanciera.SaldoCapital = Transaccion.SaldoCapital,
    TransaccionFinanciera.SaldoCapitalAnterior = Transaccion.SaldoCapitalAnterior
FROM dbo.tAYCcuentas cuenta
INNER JOIN dbo.tSDOsaldos saldo ON saldo.IdCuenta = cuenta.IdCuenta
INNER JOIN (SELECT cuenta.IdCuenta,
                   Transaccion.IdTransaccion,
                   SaldoCapital = SUM(Transaccion.CapitalGenerado + Transaccion.CapitalGeneradoVencido - Transaccion.CapitalPagado - Transaccion.CapitalPagadoVencido) OVER (PARTITION BY cuenta.IdCuenta
                                                                                                                                                                             ORDER BY Transaccion.Fecha,
                                                                                                                                                                                      Transaccion.IdTransaccion),
                   SaldoCapitalAnterior = SUM(Transaccion.CapitalGenerado + Transaccion.CapitalGeneradoVencido) OVER (PARTITION BY cuenta.IdCuenta
                                                                                                                      ORDER BY Transaccion.Fecha,
                                                                                                                               Transaccion.IdTransaccion) - (Transaccion.CapitalGenerado + Transaccion.CapitalGeneradoVencido - Transaccion.CapitalPagado - Transaccion.CapitalPagadoVencido)
            FROM dbo.vSDOtransaccionesFinancierasISNULL Transaccion
            INNER JOIN dbo.tAYCcuentas cuenta ON cuenta.IdCuenta = Transaccion.IdCuenta AND cuenta.IdTipoDProducto = 143 AND Transaccion.IdEstatus = 1
            WHERE cuenta.IdCuenta = @IdCuenta) AS Transaccion ON Transaccion.IdCuenta = cuenta.IdCuenta
INNER JOIN dbo.tSDOtransaccionesFinancieras TransaccionFinanciera ON TransaccionFinanciera.IdCuenta = cuenta.IdCuenta AND TransaccionFinanciera.IdTransaccion = Transaccion.IdTransaccion
WHERE cuenta.IdCuenta = @IdCuenta ;



