DECLARE @FechaArranque AS DATE = '20200501' ;

SELECT Pad.IdOperacion,
       Tp.Codigo,
       Pad.Serie,
       Pad.Folio,
       Pad.Fecha,
       Pad.Concepto,
       Pad.Referencia,
       Pad.Alta,
       CONCAT('DELETE dbo.tCNTpolizasD WHERE IdPolizaE = ', Pad.IdPolizaE, ';
DELETE dbo.tCNTpolizasR WHERE IdPolizaE = ', Pad.IdPolizaE, ';
DELETE dbo.tCNTpolizasE WHERE IdPolizaE = ', Pad.IdPolizaE),
       CONCAT('UPDATE dbo.tGRLoperaciones SET IdPolizaE = 0, RequierePoliza = 0, TienePoliza = 0 WHERE IdOperacion = ', OP.IdOperacion)
FROM dbo.tGRLoperaciones OP WITH(NOLOCK)
JOIN tGRLoperaciones Pad WITH(NOLOCK)ON Pad.IdOperacion = OP.IdOperacionPadre
JOIN dbo.tCTLtiposOperacion Tp WITH(NOLOCK)ON Tp.IdTipoOperacion = OP.IdTipoOperacion
WHERE Pad.Fecha < @FechaArranque AND Pad.IdEstatus = 1 AND Pad.RequierePoliza = 1 AND Pad.IdTipoOperacion = 10
ORDER BY Pad.Alta ;


