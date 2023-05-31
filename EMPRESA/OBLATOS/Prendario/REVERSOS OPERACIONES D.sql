

INSERT INTO dbo.tGRLoperacionesD( RelOperacionD, IdOperacionDOrigen, Partida, IdActivo, IdBienServicio, DescripcionBienServicio, IdTipoDDominioDestino, Concepto, Referencia, IdDivision, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdAlmacen, Cantidad, Subtotal, Total, Costo, CostoTotal, IdSucursal, IdEstructuraContableE, IdEstatus, IdCentroCostos, IdSesion, IdUsuarioAlta, Alta, IdTipoDdominio, IdTipoDominioDestino, IdTipoSubOperacion, Salida, IdEstatusDominio )
SELECT RelOperacionD = 2029137422,
       IdOperacionDOrigen = t.IdOperacionD,
       Partida,
       IdActivo,
       IdBienServicio,
       DescripcionBienServicio,
       IdTipoDDominioDestino = 2249,
       Concepto,
       Referencia,
       IdDivision,
       IdProyecto,
       IdAuxiliar,
       IdEntidad1,
       IdEntidad2,
       IdEntidad3,
       IdAlmacen,
       Cantidad,
       Subtotal = Subtotal * -1,
       Total = Total * -1,
       Costo = Costo * -1,
       CostoTotal = CostoTotal * -1,
       IdSucursal,
       IdEstructuraContableE,
       IdEstatus,
       IdCentroCostos,
       IdSesion,
       IdUsuarioAlta,
       Alta,
       IdTipoDdominio,
       IdTipoDominioDestino,
       IdTipoSubOperacion,
       Salida,
       IdEstatusDominio
FROM dbo.tGRLoperacionesD t
WHERE IdTipoSubOperacion = 38 AND IdActivo IN (12342,12343,12344,12345) --AND t.Costo > 0;



SELECT OperacionD.IdOperacionD, OperacionD.RelOperacionD, OperacionD.Partida, OperacionD.IdTipoDDominioDestino, OperacionD.IdBienServicio, OperacionD.DescripcionBienServicio, OperacionD.IdActivo, OperacionD.Concepto, OperacionD.Referencia, OperacionD.IdDivision, OperacionD.IdProyecto, OperacionD.IdAlmacen, OperacionD.Cantidad, OperacionD.Descuento, OperacionD.Subtotal, OperacionD.IdImpuesto, OperacionD.Impuestos, OperacionD.CostoTotal, OperacionD.Generado, OperacionD.Pagado, OperacionD.ImporteExento, OperacionD.ImporteGravado, OperacionD.Total, OperacionD.IdOperacionDOrigen, OperacionD.IdInformacionDepreciacion, OperacionD.IdSucursal, OperacionD.IdEstructuraContableE, OperacionD.IdEstatus, OperacionD.IdTipoDominioOrigen, OperacionD.IdTipoDominioDestino, OperacionD.IdCentroCostos, OperacionD.IdTipoSubOperacion, OperacionD.PendienteClasificar, OperacionD.IdEstatusDominio
-- DELETE OperacionD
FROM dbo.tGRLoperaciones Operacion
INNER JOIN dbo.tGRLoperacionesD OperacionD ON Operacion.IdOperacion=OperacionD.RelOperacionD
WHERE Operacion.IdOperacionPadre = 2029096722 



SELECT *
-- UPDATE d SET d.IdEstatus = 18
FROM dbo.tGRLoperacionesD d
WHERE IdOperacionD IN (1078401, 1078402, 1078403, 1078404);




SELECT Transaccion.IdTransaccion, Operacion.IdOperacion, Operacion.IdTipoOperacion, Transaccion.IdCuenta, Transaccion.Fecha, Transaccion.CapitalGenerado, CapitalPagado = ISNULL(Transaccion.CapitalPagado, 0)+ISNULL(Transaccion.CapitalPagadoVencido, 0), InteresOrdinarioPagado = ISNULL(Transaccion.InteresOrdinarioPagado, 0)+ISNULL(Transaccion.InteresOrdinarioPagadoVencido, 0), InteresMoratorioPagado = ISNULL(Transaccion.InteresMoratorioPagado, 0)+ISNULL(Transaccion.InteresMoratorioPagadoVencido, 0), IVAPagado = ISNULL(Transaccion.IVAInteresOrdinarioPagado, 0)+ISNULL(Transaccion.IVAInteresMoratorioPagado, 0), Transaccion.TotalPagado
FROM dbo.tSDOtransaccionesFinancieras Transaccion WITH( NOLOCK )
INNER JOIN dbo.tGRLoperaciones Operacion WITH( NOLOCK )ON Operacion.IdOperacion = Transaccion.IdOperacion
WHERE Transaccion.IdEstatus = 1 AND Operacion.IdOperacionPadre = 2029096722;
