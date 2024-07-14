DECLARE @IdPeriodo INT,
        @Inicio    DATE,
        @Fin       DATE;

SELECT @IdPeriodo = IdPeriodo,
       @Inicio = Inicio,
       @Fin = Fin
FROM dbo.tCTLperiodos
WHERE Codigo = '2024-05';

SELECT Cuenta.IdCuenta,
       CONCAT ('EXECUTE dbo.pFELgenerarEstadoCuentaBancario @IdSocio = ', Socio.IdSocio, ', @IdCuenta = ', Cuenta.IdCuenta, ', @IdPeriodo = ', @IdPeriodo)
FROM dbo.tGRLpersonas Persona
INNER JOIN dbo.tSCSsocios Socio ON Socio.IdPersona = Persona.IdPersona
INNER JOIN dbo.tAYCcuentas Cuenta ON Cuenta.IdSocio = Socio.IdSocio
INNER JOIN dbo.tSDOtransaccionesFinancieras Transaccion ON Transaccion.IdCuenta = Cuenta.IdCuenta
WHERE Persona.EsPersonaMoral = 1 AND
      Cuenta.IdTipoDProducto = 143 AND
      Transaccion.Fecha BETWEEN @Inicio AND @Fin AND
    ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados ) <> 0 AND
      NOT EXISTS ( SELECT 1
                   FROM dbo.tFELestadoCuentaBancario Estado
                   WHERE Estado.IdPeriodo = @IdPeriodo AND
                         Cuenta.IdCuenta = Estado.IdCuenta );

SELECT Cuenta.IdCuenta,
       CONCAT ('EXECUTE dbo.pFELgenerarEstadoCuentaBancario @IdSocio = ', Socio.IdSocio, ', @IdCuenta = ', Cuenta.IdCuenta, ', @IdPeriodo = ', @IdPeriodo),
       SUM (Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados)
FROM dbo.tGRLpersonasFisicas Persona
INNER JOIN dbo.tSCSsocios Socio ON Socio.IdPersona = Persona.IdPersona
INNER JOIN dbo.tAYCcuentas Cuenta ON Cuenta.IdSocio = Socio.IdSocio
INNER JOIN dbo.tSDOtransaccionesFinancieras Transaccion ON Transaccion.IdCuenta = Cuenta.IdCuenta
WHERE Cuenta.IdTipoDProducto = 143 AND
      Cuenta.ExentaIVA = 1 AND
      Transaccion.Fecha BETWEEN @Inicio AND @Fin AND
    ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados ) <> 0 AND
      NOT EXISTS ( SELECT 1
                   FROM dbo.tFELestadoCuentaBancario Estado
                   INNER JOIN dbo.tIMPcomprobantesFiscales c ON c.IdComprobante = Estado.IdComprobante
                   WHERE Estado.IdPeriodo = @IdPeriodo AND
                         Cuenta.IdCuenta = Estado.IdCuenta AND
                         c.Total <> ( Transaccion.InteresOrdinarioPagado + Transaccion.InteresOrdinarioPagadoVencido + Transaccion.InteresMoratorioPagado + Transaccion.InteresMoratorioPagadoVencido + Transaccion.CargosPagados ))
GROUP BY Socio.IdSocio,
         Cuenta.IdCuenta;


SELECT edo.IdPeriodo, edo.IdCuenta, edo.IdSocio
FROM dbo.tFELestadoCuentaBancario edo
INNER JOIN dbo.tIMPcomprobantesFiscales com ON com.IdComprobante = edo.IdComprobante
WHERE edo.IdPeriodo = @IdPeriodo 
GROUP BY edo.IdPeriodo,
         edo.IdCuenta,
         edo.IdSocio
HAVING COUNT(*)> 1
