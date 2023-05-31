
SELECT  InicioVigencia = DATEADD(YEAR, -1, p.FinVigencia), p.FinVigencia, p.Paquetes, r.RFC, p.IdCliente, r.RazonSocial
FROM    dbo.vVENPaquetesVencidos p
        INNER JOIN FacturacionIntelix.dbo.tFELRFCs r ON r.IdCliente = p.IdCliente
WHERE   IdDistribuidor = 2;
