DECLARE @IdDepositoE INT = ( SELECT TOP 1 IdDepositoE FROM tAYCdepositosE ORDER BY IdDepositoE DESC );

INSERT INTO dbo.tAYCdepositosD( IdDepositoE, Partida, Cuenta, Concepto, Referencia, Monto, MontoAplicado, IdCuenta, IdTransaccion, IdEstatus, Pendiente )
SELECT @IdDepositoE,
       Partida,
       Cuenta.Cuenta,
       Concepto,
       Referencia,
       Pago.Monto,
       0,
       Cuenta.IdCuenta,
       0,
       1,
       1
FROM ##Depositos Pago WITH (NOLOCK)
INNER JOIN vAYCcuentaBasica Cuenta WITH (NOLOCK) ON Pago.Cuenta = Cuenta.Cuenta COLLATE DATABASE_DEFAULT
WHERE NOT EXISTS
    ( SELECT 1 FROM tAYCdepositosD WITH (NOLOCK) WHERE IdDepositoE=@IdDepositoE );

	