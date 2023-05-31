USE IERP_MGE_NOMINA


UPDATE esta SET esta.IdEstatus = 2
FROM ##Empleados tmp
INNER JOIN dbo.tPERempleados Per ON tmp.Codigo = Per.Codigo 
INNER JOIN dbo.tCTLestatusActual esta ON esta.IdEstatusActual = Per.IdEstatusActual
WHERE tmp.Codigo IS NOT NULL


UPDATE nom SET Nom.IdEstatus = 2, Nom.IdListaDmotivoBaja = -1363, Nom.MotivoBaja = 'RENUNCIA VOLUNTARIA', Nom.FechaBaja = [Fecha Baja]
FROM ##Empleados tmp
INNER JOIN dbo.tPERempleados Per ON tmp.Codigo = Per.Codigo 
INNER JOIN dbo.tNOMempleados Nom ON Nom.IdEmpleado = Per.IdEmpleado
WHERE tmp.Codigo IS NOT NULL


