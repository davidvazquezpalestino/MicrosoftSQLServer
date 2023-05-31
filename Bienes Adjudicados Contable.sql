USE IERP_OBL ;


SELECT Periodo = Periodo.Codigo,
       CostoTotal = SUM(OperacionD.CostoTotal)
FROM dbo.tGRLoperaciones Operacion WITH(NOLOCK)
INNER JOIN dbo.tGRLoperacionesD OperacionD WITH(NOLOCK)ON OperacionD.RelOperacionD = Operacion.IdOperacion
INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK)ON Operacion.IdPeriodo = Periodo.IdPeriodo
INNER JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal = OperacionD.IdSucursal
WHERE Operacion.IdEstatus = 1 AND IdTipoOperacion = 38
GROUP BY Periodo.Codigo ;


SELECT Periodo = Periodo.Codigo,
       Cargo = SUM(PolizaD.Cargo)     
FROM dbo.tGRLoperaciones Operacion WITH(NOLOCK)
INNER JOIN dbo.tGRLoperacionesD OperacionD WITH(NOLOCK)ON OperacionD.RelOperacionD = Operacion.IdOperacion
INNER JOIN dbo.tCNTpolizasD PolizaD WITH(NOLOCK)ON PolizaD.IdPolizaE = Operacion.IdPolizaE AND PolizaD.IdOperacionDOrigen = OperacionD.IdOperacionD
INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK)ON Operacion.IdPeriodo = Periodo.IdPeriodo
WHERE Operacion.IdEstatus = 1 AND IdTipoOperacion = 38
GROUP BY Periodo.Codigo ;

