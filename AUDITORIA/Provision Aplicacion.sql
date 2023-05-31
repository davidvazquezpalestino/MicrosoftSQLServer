SELECT TransaccionProvision.IdOperacion,
       OperacionProvision = CONCAT (UPPER (TipoOperacion.Codigo), ' ', OperacionPadre.Serie, '', OperacionPadre.Folio),
       TransaccionProvision.IdTipoSubOperacion,
       TransaccionAplicacion.IdOperacion,
       TransaccionAplicacion.OperacionAplicacion
FROM dbo.tGRLoperaciones Operacion WITH( NOLOCK )
INNER JOIN dbo.tGRLoperaciones OperacionPadre WITH( NOLOCK )ON OperacionPadre.IdOperacion = Operacion.IdOperacionPadre
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH( NOLOCK )ON OperacionPadre.IdTipoOperacion = TipoOperacion.IdTipoOperacion
INNER JOIN dbo.tSDOtransacciones TransaccionProvision WITH( NOLOCK )ON TransaccionProvision.IdOperacion = Operacion.IdOperacion
LEFT JOIN( SELECT Transaccion.IdOperacion,
                  Transaccion.IdSaldoDestino,
                  Transaccion.IdTipoSubOperacion,
                  OperacionAplicacion = CONCAT (UPPER (TipoOperacion.Codigo), ' ', OperacionPadre.Serie, '', OperacionPadre.Folio)
           FROM dbo.tGRLoperaciones Operacion WITH( NOLOCK )
           INNER JOIN dbo.tGRLoperaciones OperacionPadre WITH( NOLOCK )ON OperacionPadre.IdOperacion = Operacion.IdOperacionPadre
           INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH( NOLOCK )ON OperacionPadre.IdTipoOperacion = TipoOperacion.IdTipoOperacion
           INNER JOIN dbo.tSDOtransacciones Transaccion WITH( NOLOCK )ON Transaccion.IdOperacion = Operacion.IdOperacion
           WHERE Transaccion.IdTipoSubOperacion = 502 ) TransaccionAplicacion ON TransaccionAplicacion.IdSaldoDestino = TransaccionProvision.IdSaldoDestino
WHERE OperacionPadre.Folio = 403430;
