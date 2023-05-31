DECLARE @Inicio DATE, 
		@Fin DATE, 
		@Mes DATE = DATEADD(MONTH, 0, GETDATE());

SELECT @Inicio	= DATEADD(MONTH, DATEDIFF(MONTH, 0, @Mes), 0);
SELECT @Fin		= EOMONTH(@Mes);

SELECT  c.IdCliente, c.RFC, rfc.RazonSocial, c.IdDistribuidor, us.Email, dom.Telefonos,c.IdComisionista, f.FinVigencia
FROM    dbo.tCTLclientes c
JOIN vVENPaquetesVencidos f ON f.IdCliente = c.IdCliente
JOIN FacturacionIntelix.dbo.tFELclientes rfc ON rfc.IdCliente = c.IdCliente
JOIN FacturacionIntelix.dbo.tCTLusuarios us ON us.IdCliente = c.IdCliente
JOIN FacturacionIntelix.dbo.tFELRFCs rfcs ON rfcs.IdCliente = c.IdCliente
JOIN FacturacionIntelix.dbo.tFELdomicilios dom ON dom.IdRFC = rfcs.IdRFC
WHERE  FinVigencia BETWEEN @Inicio AND @Fin
GROUP BY c.IdCliente, c.RFC, rfc.RazonSocial, c.IdDistribuidor, us.Email, dom.Telefonos,c.IdComisionista, f.FinVigencia
ORDER BY FinVigencia;



