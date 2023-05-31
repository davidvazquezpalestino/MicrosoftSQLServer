

SELECT *
-- UPDATE tr SET tr.IdSaldoDestino = Saldo.IdSaldo
FROM dbo.tGRLoperaciones op
INNER JOIN dbo.tSDOtransacciones tr ON tr.IdOperacion = op.IdOperacion
INNER JOIN(SELECT sdo.IdSaldo,
                  sdo.IdSucursal,
                  sdo.IdAuxiliar
           FROM dbo.tSDOsaldos sdo
           WHERE IdAuxiliar = -119 AND IdCuentaABCD = 492) Saldo ON Saldo.IdAuxiliar = tr.IdAuxiliar AND Saldo.IdSucursal = tr.IdSucursal
WHERE tr.IdAuxiliar = -119 AND op.IdOperacionPadre = 340512 AND tr.IdSaldoDestino <> Saldo.IdSaldo;





