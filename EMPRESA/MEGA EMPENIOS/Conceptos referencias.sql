UPDATE Transaccion
SET Transaccion.Concepto = OperacionD.Concepto,
    Transaccion.Referencia = OperacionD.Referencia
FROM dbo.tGRLoperaciones Operacion WITH ( NOLOCK )
INNER JOIN dbo.tSDOtransacciones Transaccion WITH ( NOLOCK ) ON Transaccion.IdOperacion = Operacion.IdOperacion
INNER JOIN ( SELECT OperacionD.IdOperacionD,
                 OperacionPadre.IdOperacion,
                 OperacionD.Concepto,
                 OperacionD.Referencia
             FROM dbo.tGRLoperaciones Operacion
             INNER JOIN dbo.tGRLoperaciones OperacionPadre ON OperacionPadre.IdOperacion = Operacion.IdOperacionPadre
             INNER JOIN dbo.tGRLoperacionesD OperacionD ON Operacion.IdOperacion = OperacionD.RelOperacionD
             WHERE OperacionD.IdEstatus = 1 AND OperacionPadre.IdTipoOperacion = 19 ) OperacionD ON OperacionD.IdOperacion = Transaccion.IdOperacion
WHERE Transaccion.Concepto = '';
