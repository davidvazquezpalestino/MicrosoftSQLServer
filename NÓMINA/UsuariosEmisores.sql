
SELECT * FROM tCTLusuarios 
INNER JOIN tFELclientes ON tCTLusuarios.IdCliente = tFELclientes.IdCliente 
INNER JOIN tFELRFCs ON tFELRFCs.IdCliente = tFELclientes.IdCliente 
INNER JOIN tFELemisores ON tFELemisores.IdRFC = tFELRFCs.IdRFC
WHERE tFELemisores.HabilitarNomina = 0 AND NOT tFELclientes.Llave =''