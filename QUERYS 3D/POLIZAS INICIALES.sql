SELECT Periodo = Periodo.Codigo,
       Region = Region.Descripcion,
       PolizaE.Folio,
       PolizaE.Concepto,
       CuentaPadre = CONCAT(CuentaPadre.Codigo, '', CuentaPadre.Descripcion),
       Cuenta = CONCAT(Cuenta.Codigo,' ',Cuenta.Descripcion),
       Sucursal = CONCAT(Sucursal.Codigo, ' ', Sucursal.Descripcion),
       PolizaD.Cargo,
       PolizaD.Abono,
       Empleado.IdEmpleado,
       EmpleadoResponsable = Empleado.Nombre,
       [Tipo Cuenta] = Tipo.Descripcion,
       [BALANCE / RESULTADO] = IIF(Tipo.IdTipoDPadre IN (45, 46, 47), 'BALANCE', 'RESULTADO')
FROM dbo.tCNTpolizasE PolizaE WITH(NOLOCK)
INNER JOIN dbo.tCTLdatosInicioOperaciones InicioOperacion WITH(NOLOCK)ON InicioOperacion.IdPeriodoAnteriorInicioOperaciones = PolizaE.IdPeriodo
INNER JOIN dbo.tCNTpolizasD PolizaD WITH(NOLOCK)ON PolizaD.IdPolizaE = PolizaE.IdPolizaE
INNER JOIN dbo.tCNTcuentas Cuenta ON Cuenta.IdCuentaContable = PolizaD.IdCuentaContable
INNER JOIN dbo.tCNTcuentas CuentaPadre ON Cuenta.IdCuentaContablePadre = CuentaPadre.IdCuentaContable
INNER JOIN dbo.tCTLtiposD Tipo ON Cuenta.IdTipoD = Tipo.IdTipoD
INNER JOIN dbo.tCTLsucursales Sucursal WITH(NOLOCK)ON Sucursal.IdSucursal = PolizaE.IdSucursal
INNER JOIN dbo.tCATlistasD Region WITH(NOLOCK)ON Region.IdListaD = Sucursal.IdListaDRegion
INNER JOIN dbo.vPERempleados Empleado WITH(NOLOCK)ON Empleado.IdEmpleado = Sucursal.IdEmpleadoResponsable
INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK)ON Periodo.IdPeriodo = PolizaE.IdPeriodo
WHERE PolizaE.IdEstatus = 1 AND PolizaE.IdUsuarioAlta = -1;
