
DECLARE @IdComprobante INT = 9203;

SELECT *
--UPDATE c SET c.Importe = ROUND(c.Base * 0.16, 2)
FROM dbo.tFELdetalleImpuesto c
WHERE IdComprobante = @IdComprobante

SELECT *
--UPDATE com SET com.Total = x.Total
FROM dbo.tFELcomprobantes com
INNER JOIN(SELECT Total=SUM(ROUND(c.Base * 0.16, 2)+c.Base), c.IdComprobante              
                FROM dbo.tFELcomprobantes com
          INNER JOIN dbo.tFELdetalleImpuesto c ON c.IdComprobante=com.IdComprobante
                WHERE com.IdComprobante=@IdComprobante
                GROUP BY c.IdComprobante) AS x ON x.IdComprobante=com.IdComprobante;

SELECT *
--UPDATE tFELimpuestosComprobantes SET Impuesto = x.Total
FROM dbo.tFELimpuestosComprobantes
     INNER JOIN(SELECT Total=SUM(ROUND(dt.Base * 0.16, 2)), c.IdComprobante
                FROM dbo.tFELimpuestosComprobantes c
                     INNER JOIN tFELdetalleImpuesto dt ON dt.IdComprobante=c.IdComprobante
                WHERE c.IdComprobante=@IdComprobante
                GROUP BY c.IdComprobante) AS x ON x.IdComprobante=tFELimpuestosComprobantes.IdComprobante;

