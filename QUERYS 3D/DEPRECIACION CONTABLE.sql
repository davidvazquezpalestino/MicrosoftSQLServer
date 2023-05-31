SELECT PolizaE.Folio,
       Periodo = Periodo.Codigo,
       Sucursal = Sucursal.Descripcion,
       Division = Division.Descripcion,
       Articulo = Articulo.Descripcion,
	   TipoActivo = TipoActivo.Descripcion,
       NumeroActivo = Activo.Codigo,
       Activo = Activo.DescripcionLarga,
       Cuenta = Cuenta.Codigo,
       NombreCuenta = Cuenta.Descripcion,
       PolizaD.Cargo,
       PolizaD.Abono,
       Depreciacion.Depreciacion
FROM dbo.tGRLoperaciones Operacion
INNER JOIN dbo.tCNTpolizasE PolizaE ON PolizaE.IdPolizaE = Operacion.IdPolizaE
INNER JOIN dbo.tCNTpolizasD PolizaD ON PolizaD.IdPolizaE = PolizaE.IdPolizaE
INNER JOIN dbo.tCTLperiodos Periodo ON Periodo.IdPeriodo = Operacion.IdPeriodo
INNER JOIN dbo.tCNTcuentas Cuenta ON Cuenta.IdCuentaContable = PolizaD.IdCuentaContable
INNER JOIN dbo.tGRLoperacionesD OperacionD ON OperacionD.IdOperacionD = PolizaD.IdOperacionDOrigen
INNER JOIN dbo.tCNTdivisiones Division ON Division.IdDivision = OperacionD.IdDivision
INNER JOIN dbo.tACTactivos Activo ON Activo.IdActivo = OperacionD.IdActivo
INNER JOIN dbo.tACTactivosExtendida ActivoExtendido ON ActivoExtendido.IdActivo = Activo.IdActivo
INNER JOIN dbo.tCTLtiposD TipoActivo ON ActivoExtendido.IdTipoDActivo = TipoActivo.IdTipoD
INNER JOIN dbo.tGRLbienesServicios Articulo ON Articulo.IdBienServicio = Activo.IdBienServicio
INNER JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal = OperacionD.IdSucursal
LEFT JOIN dbo.tACTinformacionDepreciacion Depreciacion ON Depreciacion.IdActivo = Activo.IdActivo AND Depreciacion.IdPeriodo = PolizaE.IdPeriodo
WHERE Operacion.IdTipoOperacion = 34 AND PolizaE.IdEstatus = 1 AND Periodo.Codigo = '2020-10';