DECLARE @IdComprobante INT = 51711;

WITH ComprobantesFiscalesD AS
( SELECT concepto.IdComprobante,
         concepto.IdComprobanteD,
         Tasa = Impuesto.TasaIVA,
         Impuesto = concepto.IVA,
         IdTipoD = 264,
         EsTrasladado = 1,
         TipoFactor = CASE WHEN Impuesto.EsIva = 1 THEN
                               'Tasa'
                           WHEN Impuesto.EsExento = 1 THEN
                               'Exento'
                           ELSE
                               NULL
                      END
  FROM dbo.tIMPcomprobantesFiscalesD concepto WITH ( NOLOCK )
  INNER JOIN dbo.tIMPimpuestos Impuesto WITH ( NOLOCK ) ON concepto.IdImpuesto = Impuesto.IdImpuesto
  WHERE concepto.IdComprobante = @IdComprobante
  UNION
  SELECT concepto.IdComprobante,
         concepto.IdComprobanteD,
         Tasa = Impuesto.TasaRetencionIVA,
         Impuesto = concepto.IVAretencion,
         IdTipoD = 264,
         EsTrasladado = 0,
         TipoFactor = CASE WHEN Impuesto.EsIva = 1 THEN
                               'Tasa'
                           WHEN Impuesto.EsExento = 1 THEN
                               'Exento'
                           ELSE
                               NULL
                      END
  FROM dbo.tIMPcomprobantesFiscalesD concepto WITH ( NOLOCK )
  INNER JOIN dbo.tIMPimpuestos Impuesto WITH ( NOLOCK ) ON concepto.IdImpuesto = Impuesto.IdImpuesto AND
                                                           Impuesto.TasaRetencionIVA <> 0
  WHERE concepto.IdComprobante = @IdComprobante
  UNION
  SELECT concepto.IdComprobante,
         concepto.IdComprobanteD,
         Tasa = Impuesto.TasaRetencionISR,
         Impuesto = concepto.ISRretencion,
         IdTipoD = 265,
         EsTrasladado = 0,
         TipoFactor = CASE WHEN Impuesto.EsIva = 1 THEN
                               'Tasa'
                           WHEN Impuesto.EsExento = 1 THEN
                               'Exento'
                           ELSE
                               NULL
                      END
  FROM dbo.tIMPcomprobantesFiscalesD concepto WITH ( NOLOCK )
  INNER JOIN dbo.tIMPimpuestos Impuesto WITH ( NOLOCK ) ON concepto.IdImpuesto = Impuesto.IdImpuesto AND
                                                           Impuesto.TasaRetencionISR <> 0
  WHERE concepto.IdComprobante = @IdComprobante
  UNION
  SELECT concepto.IdComprobante,
         concepto.IdComprobanteD,
         Tasa = Impuesto.TasaIEPS,
         Impuesto = concepto.IEPS,
         IdTipoD = 0,
         EsTrasladado = 1,
         TipoFactor = CASE WHEN Impuesto.EsIva = 1 THEN
                               'Tasa'
                           WHEN Impuesto.EsExento = 1 THEN
                               'Exento'
                           ELSE
                               NULL
                      END
  FROM dbo.tIMPcomprobantesFiscalesD concepto WITH ( NOLOCK )
  INNER JOIN dbo.tIMPimpuestos Impuesto WITH ( NOLOCK ) ON concepto.IdImpuesto = Impuesto.IdImpuesto AND
                                                           Impuesto.TasaIEPS <> 0
  WHERE concepto.IdComprobante = @IdComprobante )
SELECT concepto.IdComprobanteD,
Comprobante.ImpuestosRetenidos,
       Descripcion = TipoDimpuesto.Descripcion,
       Tasa = concepto.Tasa,    
       Impuesto = concepto.Impuesto,
       concepto.EsTrasladado,
       TipoDimpuesto.IdTipoD AS IdTipoDimpuesto,
       TipoDimpuesto.IdTipoDPadre,
       ImpuestosTrasladadosLocales = ( CASE TipoDimpuesto.IdTipoD WHEN 267 THEN
                                                                      concepto.Impuesto
                                                                  ELSE
                                                                      0
                                       END ),
       ImpuestosTrasladados = ( CASE WHEN TipoDimpuesto.IdTipoD IN (264, 269) AND
                                          concepto.EsTrasladado = 1 THEN
                                         concepto.Impuesto
                                     ELSE
                                         0
                                END ),
       ClaveImpuesto = TipoDimpuesto.Codigo,
       concepto.TipoFactor
FROM dbo.tIMPcomprobantesFiscales Comprobante WITH ( NOLOCK )
INNER JOIN ComprobantesFiscalesD concepto WITH ( NOLOCK ) ON Comprobante.IdComprobante = concepto.IdComprobante
INNER JOIN dbo.tCTLtiposD TipoDimpuesto ON TipoDimpuesto.IdTipoD = concepto.IdTipoD;


