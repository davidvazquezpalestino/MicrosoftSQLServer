
INSERT INTO dbo.tALMtransacciones(IdOperacionD, Fecha, Concepto, Referencia, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, IdProyecto, Costo, Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus)

SELECT 0, GETDATE(), ' SALIDA '+ac.Codigo, 'TRASPASO', ac.IdBienServicio, ac.IdActivo, t.IdAlmacenSalida, ac.IdDivision, ac.IdSucursal, ac.IdCentroCostos, ac.IdProyecto, ac.Costo, ac.Precio, ac.Costo, ac.Costo, ac.Costo, 0, 1, 0, 1
FROM IERP_OBL.dbo.TraspasoMercancias t
JOIN dbo.tACTactivos ac ON ac.IdActivo=t.IdActivo

UNION ALL

SELECT 0, GETDATE(), ' ENTRADA '+ac.Codigo, 'TRASPASO', ac.IdBienServicio, ac.IdActivo, t.IdAlmacenEntrada, ac.IdDivision, ac.IdSucursal, ac.IdCentroCostos, ac.IdProyecto, ac.Costo, ac.Precio, ac.Costo, ac.Costo, ac.Costo, 1, 0, 1, 1
FROM IERP_OBL.dbo.TraspasoMercancias t
JOIN dbo.tACTactivos ac ON t.IdActivo=ac.IdActivo;

SELECT * FROM dbo.tACTactivos WHERE IdActivo = 269