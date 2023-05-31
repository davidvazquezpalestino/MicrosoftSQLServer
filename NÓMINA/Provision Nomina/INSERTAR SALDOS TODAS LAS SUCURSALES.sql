DECLARE @SaldoSucursal AS TABLE
(
    IdCuentaABCD INT NULL,
    IdAuxiliar INT NULL
) ;

INSERT INTO @SaldoSucursal (IdCuentaABCD, IdAuxiliar)
SELECT IdCuentaABCD = 492,
       IdAuxiliar = 169 ;

INSERT INTO dbo.tSDOsaldos (Codigo, Descripcion, IdPersona, IdCuentaABCD, IdAuxiliar, IdDivisa, FactorDivisa, Naturaleza, IdSucursal, IdEstructuraContable, Factor, IdTipoDDominioCatalogo, IdEstatus)
SELECT Codigo = CONCAT(SaldoSucursal.AuxiliarCodigo, '-', SaldoSucursal.SucursalCodigo),
       Descripcion = SaldoSucursal.AuxiliarDescripcion,
       Deudor.IdPersona,
       Deudor.IdCuentaABCD,
       SaldoSucursal.IdAuxiliar,
       IdDivisa = 1,
       FactorDivisa = 1,
       SaldoSucursal.Naturaleza,
       SaldoSucursal.IdSucursal,
       IdEstructuraContable = Estructura.IdEstructuraContableE,
       Factor = SaldoSucursal.Naturaleza,
       IdTipoDDominioCatalogo = Estatus.IdTipoDDominio,
       IdEstatus = 1
FROM (SELECT Sucursal.IdSucursal,
             SucursalCodigo = Sucursal.Codigo,
             Auxiliar.IdAuxiliar,
             AuxiliarCodigo = Auxiliar.Codigo,
             AuxiliarDescripcion = Auxiliar.Descripcion,
             Auxiliar.Naturaleza
      FROM dbo.tCTLsucursales Sucursal
      CROSS APPLY dbo.tCNTauxiliares Auxiliar
      INNER JOIN @SaldoSucursal hhh ON hhh.IdAuxiliar = Auxiliar.IdAuxiliar
      WHERE Auxiliar.IdAuxiliar <> 0 AND Sucursal.IdSucursal > 0) AS SaldoSucursal
INNER JOIN dbo.tSDOauxiliaresAsignados AuxAsignados ON AuxAsignados.IdAuxiliar = SaldoSucursal.IdAuxiliar
INNER JOIN dbo.tGRLcuentasABCD Deudor ON Deudor.IdCuentaABCD = AuxAsignados.IdCuentaABCD
INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersona = Deudor.IdPersona
INNER JOIN dbo.tCTLestatusActual Estatus ON Estatus.IdEstatusActual = Deudor.IdEstatusActual
INNER JOIN dbo.tGRLestructurasCatalogos Estructura ON Estructura.IdEstructuraCatalogo = Deudor.IdEstructuraCatalogo
LEFT JOIN dbo.tSDOsaldos Saldo ON Saldo.IdCuentaABCD = Deudor.IdCuentaABCD AND Saldo.IdAuxiliar = SaldoSucursal.IdAuxiliar AND Saldo.IdSucursal = SaldoSucursal.IdSucursal
WHERE AuxAsignados.EsDeudor = CASE WHEN SaldoSucursal.Naturaleza = 1 THEN 1
                                   ELSE 0
                              END AND Persona.EsPersonaMoral = 1 AND SaldoSucursal.IdSucursal > 0 AND Saldo.IdSaldo IS NULL ;