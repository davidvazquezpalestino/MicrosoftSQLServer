
SELECT Cliente.IdCliente, Distribuidor.Nombre, Cliente.RazonSocial, Paquete.InicioVigencia, Paquete.FinVigencia, Paquete.Timbres, Paquete.TimbresDisponibles, Cliente.IdComisionista
FROM tVENclientesPaquetesFolios Paquete
INNER JOIN dbo.tCTLclientes Cliente ON Cliente.IdCliente = Paquete.IdCliente
INNER JOIN dbo.tFELdistribuidores Distribuidor ON Distribuidor.IdDistribuidor = Cliente.IdDistribuidor
INNER JOIN (SELECT IdClientePaqueteFolios, IdCliente, ROW=ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY FinVigencia DESC)
			FROM dbo.tVENclientesPaquetesFolios ) UltimoPaquete ON UltimoPaquete.IdClientePaqueteFolios = Paquete.IdClientePaqueteFolios
WHERE UltimoPaquete.ROW = 1 AND Cliente.IdDistribuidor = 4
ORDER BY Paquete.TimbresDisponibles


