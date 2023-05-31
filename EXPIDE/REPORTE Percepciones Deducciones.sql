DECLARE @Fecha AS DATE = '2019-01-01' ;

DECLARE @Conceptos AS TABLE
(
[PercepcionDeduccion] VARCHAR(MAX)
) ;

INSERT INTO @Conceptos(PercepcionDeduccion)
SELECT PercepcionesDeducciones = CONCAT('[', Percepcion.Concepto, '] = SUM( CASE WHEN Concepto = ''', Percepcion.Concepto, ''' THEN ImporteGrabado + ImporteExento ELSE 0 END )')
FROM dbo.tFELcomprobantes Comprobante
INNER JOIN dbo.tFELpercepcionesDeducciones Percepcion ON Percepcion.IdComprobante = Comprobante.IdComprobante
INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdComprobante = Comprobante.IdComprobante
WHERE Comprobante.IdRFCemisor = 4529 AND Complemento.FechaPago >= @Fecha
GROUP BY Percepcion.Concepto ;

DECLARE @CommandTextPercepciones AS VARCHAR(MAX) ;

SELECT @CommandTextPercepciones = COALESCE(@CommandTextPercepciones + ',', '') + PercepcionDeduccion + CHAR(10)
FROM @Conceptos ;

DROP TABLE IF EXISTS PercepcionesDeducciones ;

DECLARE @CommandText VARCHAR(MAX) = CONCAT('
SELECT ', CHAR(10), @CommandTextPercepciones, ', Comprobante.IdComprobante INTO PercepcionesDeducciones
FROM  dbo.tFELcomprobantes Comprobante
INNER JOIN dbo.tFELpercepcionesDeducciones Percepciones ON Percepciones.IdComprobante = Comprobante.IdComprobante
INNER JOIN dbo.tFELcomplementosNomina Complemento ON Complemento.IdComprobante = Comprobante.IdComprobante
WHERE NOT IdEstatus IN (2, 7) AND Comprobante.IdRFCemisor = 4529 AND Comprobante.Fecha >= ''', @Fecha, ''' ', '
GROUP BY Comprobante.IdComprobante') ;

EXECUTE(@CommandText) ;

SELECT Comprobante.Serie,
       Comprobante.Folio,
       Semana = RIGHT(CONCAT('0', DATEPART(WEEK, Comprobante.Fecha)), 2),
       Comprobante.Fecha,
       Comprobante.RFCReceptor,
       Comprobante.NombreReceptor,
       Nomina.*,
       Comprobante.FolioFiscal
FROM PercepcionesDeducciones Nomina
INNER JOIN dbo.tFELcomprobantes Comprobante ON Comprobante.IdComprobante = Nomina.IdComprobante
ORDER BY Comprobante.Fecha,
         Comprobante.Folio ;
