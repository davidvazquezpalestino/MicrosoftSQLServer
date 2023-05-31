DECLARE @IdComprobante INT = 411063;

UPDATE ComprobanteD
SET ComprobanteD.IVA = ROUND (ComprobanteD.Importe * Impuesto.TasaIVA, 2),
    ComprobanteD.IVAretencion = ROUND (ComprobanteD.Importe * Impuesto.TasaIVAretencion, 2),
    ComprobanteD.ISRretencion = ROUND (ComprobanteD.Importe * Impuesto.TasaISRretencion, 2)
FROM dbo.tFELcomprobantesD ComprobanteD
INNER JOIN dbo.tFELimpuestos Impuesto ON Impuesto.IdImpuesto = ComprobanteD.IdImpuesto
WHERE ComprobanteD.IdComprobante = @IdComprobante;

UPDATE Comprobante
SET Comprobante.ImpuestosTrasladados = x.Trasalados,
    Comprobante.ImpuestosRetenidos = x.Retenciones,
    Comprobante.Total = Comprobante.Subtotal + x.Trasalados - x.Retenciones
FROM dbo.tFELcomprobantes Comprobante
INNER JOIN(SELECT IdComprobante,
                  Trasalados = SUM (IVA) + SUM (IEPS),
                  Retenciones = SUM (IVAretencion) + SUM (ISRretencion)
           FROM dbo.tFELcomprobantesD
           WHERE IdComprobante = @IdComprobante
           GROUP BY IdComprobante) AS x ON x.IdComprobante = Comprobante.IdComprobante;

DELETE FROM dbo.tFELimpuestosComprobantes
WHERE IdComprobante = @IdComprobante;

DELETE FROM dbo.tFELdetalleImpuesto
WHERE IdComprobante = @IdComprobante;

EXEC dbo.pImpuestosComprobante @IdComprobante = @IdComprobante;

SELECT Comprobante.Subtotal,
       ImpuestosTrasladados,
       Comprobante.ImpuestosRetenidos,
       TotalCalculado = Subtotal + ImpuestosTrasladados - Comprobante.ImpuestosRetenidos,
       Total
FROM dbo.tFELcomprobantes Comprobante
WHERE IdComprobante = @IdComprobante;
