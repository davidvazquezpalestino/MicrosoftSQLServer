

SELECT Cuenta.IdCuenta,
       CONCAT ('EXECUTE dbo.pFELgenerarEstadoCuentaBancario @IdSocio = ', Socio.IdSocio, ', @IdCuenta = ', Cuenta.IdCuenta, ', @IdPeriodo = 382')
FROM dbo.tGRLpersonas Persona
INNER JOIN dbo.tSCSsocios Socio ON Socio.IdPersona = Persona.IdPersona
INNER JOIN dbo.tAYCcuentas Cuenta ON Cuenta.IdSocio = Socio.IdSocio
INNER JOIN dbo.tSDOtransaccionesFinancieras Transaccion ON Transaccion.IdCuenta = Cuenta.IdCuenta
WHERE Persona.EsPersonaMoral = 1
      AND Cuenta.IdEstatus = 1
      AND Cuenta.IdTipoDProducto = 143
      AND Transaccion.Fecha BETWEEN '2023-05-01' AND '2023-05-31'
      AND ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados ) <> 0;

SELECT Cuenta.IdCuenta,
       CONCAT ('EXECUTE dbo.pFELgenerarEstadoCuentaBancario @IdSocio = ', Socio.IdSocio, ', @IdCuenta = ', Cuenta.IdCuenta, ', @IdPeriodo = 382')
FROM dbo.tGRLpersonasFisicas Persona
INNER JOIN dbo.tSCSsocios Socio ON Socio.IdPersona = Persona.IdPersona
INNER JOIN dbo.tAYCcuentas Cuenta ON Cuenta.IdSocio = Socio.IdSocio
INNER JOIN dbo.tSDOtransaccionesFinancieras Transaccion ON Transaccion.IdCuenta = Cuenta.IdCuenta
WHERE Cuenta.IdEstatus = 1
      AND Cuenta.IdTipoDProducto = 143
      AND Cuenta.ExentaIVA = 1
      AND Transaccion.Fecha BETWEEN '2023-05-01' AND '2023-05-31'
      AND ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados ) <> 0;
