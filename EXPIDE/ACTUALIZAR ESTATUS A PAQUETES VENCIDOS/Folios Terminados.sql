USE ServiciosIntelix

SELECT  rfc.IdRFC,
		cli.RFC,
		rfc.RazonSocial,
        c.InicioVigencia,		
        c.FinVigencia ,
		c.MontoDeposito ,
        TimbresAdquiridos = c.Timbres,                
        c.TimbresDisponibles ,
        Estatus = e.Descripcion		
FROM    dbo.tVENclientesPaquetesFolios c			 WITH(NOLOCK)
        JOIN ( SELECT IdCliente, FinVigencia = MAX(FinVigencia), IdClientePaqueteFolios = MAX(IdClientePaqueteFolios)
               FROM   dbo.tVENclientesPaquetesFolios WITH(NOLOCK)
               GROUP BY IdCliente
             ) paquetes ON paquetes.IdClientePaqueteFolios = c.IdClientePaqueteFolios
        JOIN dbo.tCTLclientes cli					 WITH(NOLOCK) ON cli.IdCliente = c.IdCliente
		JOIN [FacturacionIntelix].[dbo].tFELRFCs rfc WITH(NOLOCK) ON rfc.IdCliente = cli.IdCliente
		JOIN dbo.tCTLestatus e						 WITH(NOLOCK) ON c.IdEstatus = e.IdEstatus
WHERE  NOT e.IdEstatus IN (1, 2)
ORDER BY c.TimbresDisponibles;



