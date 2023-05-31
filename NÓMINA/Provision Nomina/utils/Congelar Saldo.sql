SELECT *
FROM dbo.tAYCdepositosE ORDER BY IdDepositoE DESC


 SELECT saldo.IdCuenta,  p.Monto 
--	UPDATE saldo SET saldo.SaldoCongeladoAhorroCredito = saldo.SaldoCongeladoAhorroCredito + p.Monto
FROM dbo.tAYCdepositosD p
INNER JOIN dbo.tSDOsaldos saldo ON p.IdCuenta = saldo.IdCuenta
where p.IdDepositoE = 172

