SET LANGUAGE Spanish
SELECT  Mes = DATENAME(MONTH, InicioVigencia) ,
        Distribuidor = IIF(IdDistribuidor = 1, 'Intelix', 'Daniel') ,
        Timbres = SUM(Timbres) ,
        Paquetes = COUNT(IdCliente)
FROM    dbo.tVENclientesPaquetesFolios
WHERE   IdCliente != 0
        AND IdCliente != 165
        AND InicioVigencia BETWEEN '20170101' AND '20170531'
GROUP BY IdDistribuidor ,
        DATENAME(MONTH, InicioVigencia) ,
        MONTH(InicioVigencia)
ORDER BY MONTH(InicioVigencia)
