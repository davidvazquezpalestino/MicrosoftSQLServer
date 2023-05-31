
SELECT IdBienServicio = PercepcionDeduccion.IdBienServicio, Codigo = PercepcionDeduccion.Codigo, PercepcionDeduccion = PercepcionDeduccion.Descripcion, Division = Division.Descripcion, sub.Rubro, sub.Codigo, sub.Cuenta
FROM dbo.vGRLbienesServicios PercepcionDeduccion
INNER JOIN dbo.tCNTdivisiones Division ON Division.IdDivision = PercepcionDeduccion.IdDivision
LEFT JOIN
   ( SELECT Concepto.IdBienServicio, Concepto = Concepto.Descripcion, Rubro = Tipo.Descripcion, Cuenta.Codigo, Cuenta = Cuenta.Descripcion
     FROM dbo.vGRLbienesServicios Concepto
     LEFT JOIN dbo.tCNTestructurasContablesD EstructuraContable ON EstructuraContable.IdBienServicio = Concepto.IdBienServicio
     LEFT JOIN dbo.tCTLdominiosRubros Rubro ON Rubro.IdDominioRubro = EstructuraContable.IdDominioRubro
     LEFT JOIN dbo.tCTLtiposD Tipo ON Tipo.IdTipoD = Rubro.IdTipoDRubro
     LEFT JOIN dbo.tCNTcuentas Cuenta ON Cuenta.IdCuentaContable = EstructuraContable.IdCuentaContable
     WHERE Concepto.IdTipoDDominio = 1452 AND EstructuraContable.IdEstructuraContableE = 7 AND Rubro.IdTipoDRubro IN (1468, 1469)) AS sub ON sub.IdBienServicio = PercepcionDeduccion.IdBienServicio
WHERE PercepcionDeduccion.IdEstatus = 1 AND PercepcionDeduccion.IdTipoDDominio = 1452
ORDER BY sub.Rubro ;

