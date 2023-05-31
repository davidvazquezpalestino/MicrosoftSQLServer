DECLARE @IdSiguientePerido INT = dbo.fGETidPeriodo(CURRENT_TIMESTAMP) ;

SELECT *
--DELETE h
FROM tSDOhistorialDeudoras h WITH(NOLOCK)
INNER JOIN dbo.tCTLperiodos p WITH(NOLOCK)ON p.IdPeriodo = h.IdPeriodo
INNER JOIN dbo.tAYCcuentasEstadisticas ce WITH(NOLOCK)ON ce.IdCuenta = h.IdCuenta
WHERE ce.FechaBaja > '1900-01-01' AND IdEstatus = 7 AND p.Inicio > ce.FechaBaja AND h.IdPeriodo < @IdSiguientePerido 


