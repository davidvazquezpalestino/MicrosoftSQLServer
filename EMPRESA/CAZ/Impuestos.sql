
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
WHERE edo.IdPeriodo = 402
  AND NOT EXISTS ( SELECT 1
                   FROM dbo.tIMPimpuestosComprobantes imp
                   WHERE imp.IdComprobante = Det.IdComprobante AND imp.TipoFactor = Det.TipoFactor)
GROUP BY Det.IdComprobante,
         Det.TasaCuota,
         Det.EsTrasladado,
		 Det.TipoFactor,
         Det.Impuesto;


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
WHERE Det.IdComprobante = 74939
  AND NOT EXISTS ( SELECT 1
                   FROM dbo.tIMPimpuestosComprobantes imp
                   WHERE imp.IdComprobante = Det.IdComprobante AND imp.TipoFactor = Det.TipoFactor)
GROUP BY Det.IdComprobante,
         Det.TasaCuota,
         Det.EsTrasladado,
		 Det.TipoFactor,
         Det.Impuesto;  

