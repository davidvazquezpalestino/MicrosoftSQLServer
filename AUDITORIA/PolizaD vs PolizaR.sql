SELECT D.IdPolizaE,
       D.IdCuentaContable,
       R.IdCuentaContable
FROM dbo.tCNTpolizasR R
JOIN dbo.tCNTpolizasD D ON D.IdPolizaR = R.IdPolizaR
WHERE D.IdCuentaContable <> R.IdCuentaContable AND R.IdPolizaR <> 0 ;

