DECLARE @IdPeriodo INT,
        @Inicio    DATE,
        @Fin       DATE;

SELECT @IdPeriodo = IdPeriodo,
       @Inicio = Inicio,
       @Fin = Fin
FROM dbo.tCTLperiodos
WHERE Codigo = '2025-02';

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


    INSERT INTO dbo.tFELdetalleImpuesto( IdComprobante, IdComprobanteD, Base, Impuesto, TipoFactor, TasaCuota, Importe, EsTrasladado )
    SELECT I.IdComprobante,
       I.IdComprobanteD,
       I.Base,
       I.Impuesto,
       I.TipoFactor,
       I.TasaCuota,
       I.Importe,
       I.EsTrasladado
    FROM dbo.vImpuestosComprobante I WITH( NOLOCK )
INNER JOIN dbo.tFELestadoCuentaBancario edo ON edo.IdComprobante = i.IdComprobante
WHERE edo.IdPeriodo = 418

INSERT INTO dbo.tIMPimpuestosComprobantes ( IdComprobante, Descripcion, Tasa, Impuesto, EsTrasladado, IdTipoDimpuesto, ClaveImpuesto, 
											TasaCuota, TipoFactor, Base )
SELECT Det.IdComprobante,
       Descripcion = 'IVA',
       Det.TasaCuota,
       Importe = SUM (Det.Importe),
       Det.EsTrasladado,
       IdTipoDimpuesto = 264,
       Det.Impuesto,
       Det.TasaCuota,
       Det.TipoFactor,
       Base = SUM (Det.Base)
FROM dbo.tFELdetalleImpuesto Det
INNER JOIN dbo.tFELestadoCuentaBancario edo ON edo.IdComprobante = Det.IdComprobante
WHERE edo.IdPeriodo = 418
  AND NOT EXISTS ( SELECT 1
                   FROM dbo.tIMPimpuestosComprobantes imp
                   WHERE imp.IdComprobante = Det.IdComprobante AND imp.TipoFactor = Det.TipoFactor)
GROUP BY Det.IdComprobante,
         Det.TasaCuota,
         Det.EsTrasladado,
		 Det.TipoFactor,
         Det.Impuesto;


SELECT p.Nombre, *
--  UPDATE cf SET cf.RFCReceptor = 'XAXX010101000', cf.IdUsoCfdi = 23, cf.RegimenFiscalReceptor ='616', cf.ReceptorCodigoPostal = '95000'
-- UPDATE cf SET cf.NombreReceptor = p.RazonSocial
FROM dbo.tIMPcomprobantesFiscales cf
INNER JOIN dbo.tFELestadoCuentaBancario ed ON ed.IdComprobante = cf.IdComprobante
INNER JOIN dbo.tGRLpersonas p ON p.IdPersona = cf.IdPersona
WHERE ed.IdPeriodo = 417
AND cf.NombreReceptor = ''
AND cf.UUID = '';



SELECT *
-- DELETE Det
FROM dbo.tIMPimpuestosComprobantes Det
INNER JOIN dbo.tFELestadoCuentaBancario edo ON edo.IdComprobante = Det.IdComprobante
WHERE edo.IdPeriodo = 417

INSERT INTO dbo.tIMPimpuestosComprobantes ( IdComprobante, Descripcion, Tasa, Impuesto, EsTrasladado, IdTipoDimpuesto, ClaveImpuesto, 
											TasaCuota, TipoFactor, Base )
SELECT Det.IdComprobante,
       Descripcion = 'IVA',
       Det.TasaCuota,
       Importe = SUM (Det.Importe),
       Det.EsTrasladado,
       IdTipoDimpuesto = 264,
       Det.Impuesto,
       Det.TasaCuota,
       Det.TipoFactor,
       Base = SUM (Det.Base)
FROM dbo.tFELdetalleImpuesto Det
INNER JOIN dbo.tFELestadoCuentaBancario edo ON edo.IdComprobante = Det.IdComprobante
WHERE edo.IdPeriodo = 417
  AND NOT EXISTS ( SELECT 1
                   FROM dbo.tIMPimpuestosComprobantes imp
                   WHERE imp.IdComprobante = Det.IdComprobante AND imp.TipoFactor = Det.TipoFactor)
GROUP BY Det.IdComprobante,
         Det.TasaCuota,
         Det.EsTrasladado,
		 Det.TipoFactor,
         Det.Impuesto;


--DELETE FROM dbo.tIMPimpuestosComprobantes WHERE IdComprobante = 75564

INSERT INTO dbo.tIMPimpuestosComprobantes ( IdComprobante, Descripcion, Tasa, Impuesto, EsTrasladado, IdTipoDimpuesto, ClaveImpuesto, 
											TasaCuota, TipoFactor, Base )
SELECT Det.IdComprobante,
       Descripcion = 'IVA',
       Det.TasaCuota,
       Importe = SUM (Det.Importe),
       Det.EsTrasladado,
       IdTipoDimpuesto = 264,
       Det.Impuesto,
       Det.TasaCuota,
       Det.TipoFactor,
       Base = SUM (Det.Base)
FROM dbo.tFELdetalleImpuesto Det
WHERE Det.IdComprobante = 75564
GROUP BY Det.IdComprobante,
         Det.TasaCuota,
         Det.EsTrasladado,
         Det.Impuesto,
         Det.TipoFactor


EXECUTE dbo.pImpuestosComprobante