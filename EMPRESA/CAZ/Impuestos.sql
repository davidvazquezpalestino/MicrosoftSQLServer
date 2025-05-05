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
WHERE I.IdComprobante = 77641

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
WHERE Det.IdComprobante = 77641
  AND NOT EXISTS ( SELECT 1
                   FROM dbo.tIMPimpuestosComprobantes imp
                   WHERE imp.IdComprobante = Det.IdComprobante AND imp.TipoFactor = Det.TipoFactor)
GROUP BY Det.IdComprobante,
         Det.TasaCuota,
         Det.EsTrasladado,
		 Det.TipoFactor,
         Det.Impuesto;