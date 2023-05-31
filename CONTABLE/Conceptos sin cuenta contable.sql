
SELECT IdBienServicio = Concepto.IdBienServicio,
       Codigo = Concepto.Codigo,
       Concepto = Concepto.Descripcion,
       Division = Division.Descripcion,
       sub.Rubro,
       sub.Codigo,
       sub.Cuenta
FROM dbo.vGRLbienesServicios Concepto
INNER JOIN dbo.tCNTdivisiones Division ON Division.IdDivision = Concepto.IdDivision
LEFT JOIN(SELECT Concepto.IdBienServicio,
                 Concepto = Concepto.Descripcion,
                 Rubro = Tipo.Descripcion,
                 Cuenta.Codigo,
                 Cuenta = Cuenta.Descripcion
          FROM dbo.vGRLbienesServicios Concepto
          LEFT JOIN dbo.tCNTestructurasContablesD EstructuraContable ON EstructuraContable.IdBienServicio = Concepto.IdBienServicio
          LEFT JOIN dbo.tCTLdominiosRubros Rubro ON Rubro.IdDominioRubro = EstructuraContable.IdDominioRubro
          LEFT JOIN dbo.tCTLtiposD Tipo ON Tipo.IdTipoD = Rubro.IdTipoDRubro
          LEFT JOIN dbo.tCNTcuentas Cuenta ON Cuenta.IdCuentaContable = EstructuraContable.IdCuentaContable
          WHERE Concepto.IdTipoDDominio = 1575 AND EstructuraContable.IdEstructuraContableE = -7 AND Rubro.IdTipoDRubro = 156) AS sub ON sub.IdBienServicio = Concepto.IdBienServicio
WHERE Concepto.IdTipoDDominio = 1575
ORDER BY sub.Rubro ;





