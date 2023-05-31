

--SELECT * FROM dbo.tCNTcuentas WHERE Codigo = '102000003'


WITH hh AS (
SELECT Poliza.Fecha, Poliza.IdPeriodo, PolizaD.IdTransaccion, PolizaD.Cargo, PolizaD.Abono
FROM dbo.tCNTpolizasE Poliza
INNER JOIN dbo.tCNTpolizasD PolizaD ON PolizaD.IdPolizaE=Poliza.IdPolizaE
WHERE Poliza.IdEstatus=1 AND PolizaD.IdCuentaContable=1212 ),

hhh AS (
SELECT Operacion.Fecha, Operacion.IdPeriodo, Transaccion.IdTransaccion, Cargo=Transaccion.SubTotalGenerado, Abono=Transaccion.SubTotalPagado
FROM dbo.tSDOtransacciones Transaccion
INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion=Transaccion.IdOperacion
WHERE Transaccion.IdEstatus=1 AND Transaccion.IdSaldoDestino=3489 )

SELECT *
FROM hh
LEFT JOIN hhh ON hhh.IdTransaccion = hh.IdTransaccion AND hhh.IdPeriodo = hh.IdPeriodo
WHERE hhh.IdTransaccion IS NULL
ORDER BY hh.Fecha, hhh.Fecha


SELECT op.IdTipoOperacion, op.Folio, tr.IdTransaccion, tr.IdOperacion, tr.IdTipoSubOperacion, tr.Fecha, tr.Descripcion, tr.IdSaldoDestino, tr.IdTipoDDominioDestino, tr.IdAuxiliar, tr.IdProyecto, tr.IdCuenta, tr.IdBienServicio, tr.IdDivisa, tr.FactorDivisa, tr.TipoMovimiento, tr.MontoSubOperacion, tr.Naturaleza, tr.TotalCargos, tr.TotalAbonos, tr.CambioNeto, tr.SubTotalGenerado, tr.SubTotalPagado, tr.Concepto, tr.Referencia, tr.IdSucursal, tr.IdEstructuraContableE, tr.IdCheque, tr.IdEstatus
-- UPDATE tr SET tr.IdEstatus = 1
FROM dbo.tGRLoperaciones op
INNER JOIN dbo.tSDOtransacciones tr ON tr.IdOperacion=op.IdOperacion
WHERE tr.IdTransaccion = 21853;