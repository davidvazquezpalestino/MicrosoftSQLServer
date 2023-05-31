DECLARE @IdPeriodo INT = dbo.fGETidPeriodo ('20210930');

SELECT Poliza.IdPolizaE, Poliza.Concepto,
    Poliza.Folio,
    Poliza.Fecha,
    Cuenta.Codigo,
    PolizaD.IdCentroCostos, Cuenta.Descripcion,
    'CUENTAS DE BALANCE CON CENTRO DE COSTOS INCORRECTOS.'
-- UPDATE PolizaD SET PolizaD.IdCentroCostos = -1
-- UPDATE PolizaR SET PolizaR.IdCentroCostos = -1
FROM dbo.tCNTpolizasE Poliza WITH (NOLOCK)
INNER JOIN dbo.tCNTpolizasD PolizaD WITH (NOLOCK) ON PolizaD.IdPolizaE = Poliza.IdPolizaE
INNER JOIN dbo.tCNTpolizasR PolizaR WITH(NOLOCK) ON PolizaR.IdPolizaR = PolizaD.IdPolizaR
INNER JOIN dbo.tCNTcuentas Cuenta WITH (NOLOCK) ON Cuenta.IdCuentaContable = PolizaD.IdCuentaContable
WHERE Poliza.IdEstatus = 1 AND Cuenta.IdTipoD IN (51, 52, 53, 54, 55, 56, 57) AND Cuenta.IdCuentaContable > 0 AND PolizaD.IdCentroCostos <> -1 --AND Cuenta.Codigo ='1070307000006'
ORDER BY Poliza.Fecha

