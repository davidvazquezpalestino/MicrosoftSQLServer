DECLARE @IdPeriodo INT;
DECLARE @Fecha DATE = CURRENT_TIMESTAMP;

SELECT @IdPeriodo = dbo.fGETidPeriodo (CURRENT_TIMESTAMP);

DECLARE @IdOperacion INT;

EXECUTE dbo.pACToperaciones @TipoOperacion = 'INSERT',
                            @idOperacion = @IdOperacion OUTPUT,
                            @IdOperacionPadre = 0,
                            @IdTipoOperacion = 59,
                            @idPeriodo = @IdPeriodo,
                            @IdSucursal = 2,
                            @IdSesion = 0,
                            @Fecha = @Fecha,
                            @Concepto = 'TRASPASO DE ARTICULOS',
                            @Validar = 0,
                            @fechaTrabajo = @Fecha;

SELECT @IdOperacion;

INSERT INTO dbo.tGRLoperacionesD ( RelOperacionD, Partida, IdBienServicio, DescripcionBienServicio, IdActivo, Concepto, Referencia, IdDivision, Cantidad, IdSucursal, IdAlmacen, IdEstructuraContableE, IdEstatus, IdUsuarioAlta, Alta, IdCentroCostos, IdEstatusDominio )
SELECT IdOperacion = 2032502434,
       Partida = ROW_NUMBER () OVER ( ORDER BY a.IdActivo ),
       a.IdBienServicio,
       a.DescripcionLarga,
       a.IdActivo,
       Concepto = 'TRASPASO DE ARTÍCULOS',
       Referencia = a.Codigo,
       a.IdDivision,
       Cantidad = 1,
       a.IdSucursal,
       a.IdAlmacen,
       a.IdEstructuraContableE,
       a.IdEstatus,
       IdUsuarioAlta = -1,
       CURRENT_TIMESTAMP,
       1,
       1
FROM ##Traspasos p
INNER JOIN dbo.tACTactivos a ON CodigoParte = a.Codigo COLLATE DATABASE_DEFAULT
WHERE CodigoParte IS NOT NULL
ORDER BY a.IdActivo;

INSERT INTO dbo.tALMtransacciones ( IdOperacionD, Fecha, Concepto, Referencia, IdProyecto, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, Costo, Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus )
SELECT OperacionD.IdOperacionD,
       Fecha = CURRENT_TIMESTAMP,
       Concepto = 'TRASPASO DE ARTÍCULOS M21',
       Referencia = 'ENTRADA',
       IdProyecto = 0,
       OperacionD.IdBienServicio,
       Activo.IdActivo,
       Activo.IdAlmacen,
       OperacionD.IdDivision,
       Activo.IdSucursal,
       OperacionD.IdCentroCostos,
       Activo.Costo,
       Activo.Precio,
       Activo.Costo,
       Activo.Costo,
       Activo.Precio,
       Entrada = 1,
       Salida = 0,
       Existencia = 1,
       Activo.IdEstatus
FROM dbo.tGRLoperacionesD OperacionD
INNER JOIN dbo.tACTactivos Activo ON Activo.IdActivo = OperacionD.IdActivo
WHERE OperacionD.IdEstatus = 1 AND OperacionD.RelOperacionD = 2032502434
ORDER BY Activo.IdActivo;

INSERT INTO dbo.tALMtransacciones ( IdOperacionD, Fecha, Concepto, Referencia, IdProyecto, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, Costo, Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus )
SELECT OperacionD.IdOperacionD,
       Fecha = CURRENT_TIMESTAMP,
       Concepto = 'TRASPASO DE ARTÍCULOS SALIDA',
       Referencia = 'SALIDA',
       IdProyecto = 0,
       OperacionD.IdBienServicio,
       OperacionD.IdActivo,
       transaccion.IdAlmacen,
       OperacionD.IdDivision,
       transaccion.IdSucursal,
       OperacionD.IdCentroCostos,
       transaccion.Costo,
       transaccion.Precio,
       transaccion.CostoPromedio,
       transaccion.CostoTotal,
       transaccion.ImporteTotal,
       Entrada = 0,
       Salida = 1,
       Existencia = 0,
       transaccion.IdEstatus
FROM dbo.tGRLoperacionesD OperacionD
INNER JOIN ( SELECT transaccion.IdActivo,
                    transaccion.IdAlmacen,
                    transaccion.IdSucursal,
                    transaccion.Costo,
                    transaccion.Precio,
                    CostoPromedio,
                    CostoTotal,
                    ImporteTotal,
                    Entrada,
                    Salida,
                    Existencia,
                    IdEstatus,
                    Partida = ROW_NUMBER () OVER ( PARTITION BY transaccion.IdActivo
                                                   ORDER BY IdTransaccion DESC )
             FROM dbo.tALMtransacciones transaccion ) transaccion ON transaccion.IdActivo = OperacionD.IdActivo
WHERE transaccion.Partida = 1 AND OperacionD.RelOperacionD = 2032502434 AND CAST(Alta AS DATE) = CAST(CURRENT_TIMESTAMP AS DATE);

INSERT INTO dbo.tALMtransacciones ( IdOperacionD, Fecha, Concepto, Referencia, IdProyecto, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, Costo, Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus )
SELECT OperacionD.IdOperacionD,
       Fecha = CURRENT_TIMESTAMP,
       Concepto = 'TRASPASO DE ARTÍCULOS ENTRADA',
       Referencia = 'ENTRADA',
       IdProyecto = 0,
       OperacionD.IdBienServicio,
       OperacionD.IdActivo,
       IdAlmacen = 2,
       OperacionD.IdDivision,
       IdSucursal = 2,
       OperacionD.IdCentroCostos,
       transaccion.Costo,
       transaccion.Precio,
       transaccion.CostoPromedio,
       transaccion.CostoTotal,
       transaccion.ImporteTotal,
       Entrada = 1,
       Salida = 0,
       Existencia = 1,
       transaccion.IdEstatus
FROM dbo.tGRLoperacionesD OperacionD
INNER JOIN ( SELECT transaccion.IdActivo,
                    transaccion.IdAlmacen,
                    transaccion.IdSucursal,
                    transaccion.Costo,
                    transaccion.Precio,
                    CostoPromedio,
                    CostoTotal,
                    ImporteTotal,
                    Entrada,
                    Salida,
                    Existencia,
                    IdEstatus,
                    Partida = ROW_NUMBER () OVER ( PARTITION BY transaccion.IdActivo
                                                   ORDER BY IdTransaccion DESC )
             FROM dbo.tALMtransacciones transaccion ) transaccion ON transaccion.IdActivo = OperacionD.IdActivo
WHERE transaccion.Partida = 1 AND OperacionD.RelOperacionD = 2032502434;

SELECT transaccion.IdAlmacen,
       Activo.IdAlmacen,
       *
-- UPDATE Activo SET Activo.IdSucursal = 2, Activo.DisponibleVenta = 1--, Activo.Precio = p.PrecioFinal, Activo.IdAlmacen = transaccion.IdAlmacen
FROM dbo.tALMtransacciones transaccion
INNER JOIN dbo.tGRLoperacionesD opd ON opd.IdOperacionD = transaccion.IdOperacionD AND opd.IdActivo = transaccion.IdActivo
INNER JOIN dbo.tACTactivos Activo ON Activo.IdActivo = transaccion.IdActivo
WHERE opd.RelOperacionD = 2032502434 AND transaccion.Entrada = 1;



SELECT *
FROM dbo.tACTactivos a
INNER JOIN dbo.tACTbienesAdjudicados b ON b.IdActivo = a.IdActivo
INNER JOIN dbo.tALMtransacciones t ON t.IdActivo = a.IdActivo
WHERE IdOperacion = 2032502434


SELECT *
-- DELETE t
FROM dbo.tALMtransacciones t
WHERE Fecha = '2021-12-08' AND t.Referencia = 'ENTRADA';