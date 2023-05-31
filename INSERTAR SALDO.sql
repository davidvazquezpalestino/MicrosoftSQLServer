

DECLARE @IdAuxiliar INT = -100 ;

--INSERT INTO dbo.tSDOsaldos( Codigo, Descripcion, IdPersona, IdCuentaABCD, IdAuxiliar, IdDivisa, FactorDivisa, Naturaleza, IdSucursal, IdEstructuraContable, Factor, IdTipoDDominioCatalogo, IdEstatus )
SELECT Codigo = CONCAT (Auxiliar.Codigo, ' ', Sucursal.Codigo),
    Descripcion = Auxiliar.Descripcion,
    Empleado.IdPersona,
    Empleado.IdCuentaABCD,
    Auxiliar.IdAuxiliar,
    IdDivisa = 1,
    FactorDivisa = 1,
    Auxiliar.Naturaleza,
    Sucursal.IdSucursal,
    IdEstructuraContable = Estructura.IdEstructuraContableE,
    Factor = Auxiliar.Naturaleza,
    IdTipoDDominioCatalogo = 700,
    IdEstatus = 1
FROM dbo.tCNTauxiliares Auxiliar
INNER JOIN dbo.tSDOauxiliaresAsignados AuxAsignados ON AuxAsignados.IdAuxiliar = Auxiliar.IdAuxiliar
INNER JOIN dbo.tGRLcuentasABCD DeudorAcreedor ON DeudorAcreedor.IdCuentaABCD = AuxAsignados.IdCuentaABCD
INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdCuentaABCD = AuxAsignados.IdCuentaABCD
INNER JOIN dbo.tGRLestructurasCatalogos Estructura ON Estructura.IdEstructuraCatalogo = DeudorAcreedor.IdEstructuraCatalogo
INNER JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal = Empleado.IdSucursal
LEFT JOIN dbo.tSDOsaldos Saldo ON Auxiliar.IdAuxiliar = Saldo.IdAuxiliar AND Empleado.IdCuentaABCD = Saldo.IdCuentaABCD AND Saldo.IdSucursal = Sucursal.IdSucursal
WHERE Sucursal.IdSucursal > 0 AND Auxiliar.IdAuxiliar = @IdAuxiliar AND AuxAsignados.EsDeudor = CASE WHEN Auxiliar.Naturaleza = 1 THEN
                                                                                                          1
                                                                                                     ELSE 0
                                                                                                END AND Empleado.IdEmpleado IN (72) AND ( Saldo.IdSaldo IS NULL OR Saldo.IdEstatus = 1 ) ;
GO


