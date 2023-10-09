DECLARE @IdPeriodo INT,
        @Inicio    DATE,
        @Fin       DATE;

SELECT @IdPeriodo = IdPeriodo,
       @Inicio = Inicio,
       @Fin = Fin
FROM dbo.tCTLperiodos
WHERE Codigo = '2023-09';

SELECT Cuenta.IdCuenta,
       CONCAT ('EXECUTE dbo.pFELgenerarEstadoCuentaBancario @IdSocio = ', Socio.IdSocio, ', @IdCuenta = ', Cuenta.IdCuenta, ', @IdPeriodo = ', @IdPeriodo)
FROM dbo.tGRLpersonas Persona
INNER JOIN dbo.tSCSsocios Socio ON Socio.IdPersona = Persona.IdPersona
INNER JOIN dbo.tAYCcuentas Cuenta ON Cuenta.IdSocio = Socio.IdSocio
INNER JOIN dbo.tSDOtransaccionesFinancieras Transaccion ON Transaccion.IdCuenta = Cuenta.IdCuenta
WHERE Persona.EsPersonaMoral = 1 AND
      --Cuenta.IdEstatus IN (1, 7) AND
      Cuenta.IdTipoDProducto = 143 AND
      Transaccion.Fecha BETWEEN @Inicio AND @Fin AND
    ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados ) <> 0 AND
      NOT EXISTS ( SELECT 1
                   FROM dbo.tFELestadoCuentaBancario Estado
                   WHERE Estado.IdPeriodo = @IdPeriodo AND
                         Cuenta.IdCuenta = Estado.IdCuenta );

SELECT Cuenta.IdCuenta,
       CONCAT ('EXECUTE dbo.pFELgenerarEstadoCuentaBancario @IdSocio = ', Socio.IdSocio, ', @IdCuenta = ', Cuenta.IdCuenta, ', @IdPeriodo = ', @IdPeriodo)
FROM dbo.tGRLpersonasFisicas Persona
INNER JOIN dbo.tSCSsocios Socio ON Socio.IdPersona = Persona.IdPersona
INNER JOIN dbo.tAYCcuentas Cuenta ON Cuenta.IdSocio = Socio.IdSocio
INNER JOIN dbo.tSDOtransaccionesFinancieras Transaccion ON Transaccion.IdCuenta = Cuenta.IdCuenta
WHERE --Cuenta.IdEstatus = 1 AND
    Cuenta.IdTipoDProducto = 143 AND
    Cuenta.ExentaIVA = 1 AND
    Transaccion.Fecha BETWEEN @Inicio AND @Fin AND
    ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados ) <> 0 AND
    NOT EXISTS ( SELECT 1
                 FROM dbo.tFELestadoCuentaBancario Estado
                 WHERE Estado.IdPeriodo = @IdPeriodo AND
                       Cuenta.IdCuenta = Estado.IdCuenta )
GROUP BY Socio.IdSocio,
         Cuenta.IdCuenta;
GO