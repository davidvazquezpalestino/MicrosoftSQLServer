

--EXEC dbo.pACToperaciones @TipoOperacion = 'INSERT', -- varchar(20)                       
--                         @IdTipoOperacion = 59, -- int
--						 @idOperacion = 0,
--                         @IdSucursal = 2,
--                         @idPeriodo = 406, -- int
--                         @IdSesion = 0, -- int
--                         @Fecha = '20200324' ,
--                         @Concepto = 'TRASPASO DE ARTÍCULOS',
--                         @Validar = 0; -- date


--INSERT INTO dbo.tGRLoperacionesD(RelOperacionD, Partida, IdActivo, IdBienServicio, DescripcionBienServicio, Concepto, Referencia,
--                                 IdDivision, Cantidad, IdSucursal, IdEstructuraContableE, IdEstatus, IdCentroCostos, IdUsuarioAlta, Alta, IdTipoDdominio,
--                                 IdTipoDominioDestino, IdTipoDDominioDestino, IdTipoSubOperacion, Salida, IdEstatusDominio)
--SELECT RelOperacionD = 1997353675,
--       ROW_NUMBER() OVER (ORDER BY g.Id),
--       a.IdActivo,
--       IdBienServicio,
--       DescripcionLarga,
--       Concepto = 'TRASPASO DE ARTÍCULOS',
--       Referencia,
--       IdDivision = a.IdDivision,
--       Cantidad = 1,      
--       a.IdSucursal,
--       IdEstructuraContableE,
--       a.IdEstatus,
--       IdCentroCostos,
       
--       IdUsuarioAlta = -1,
--       GETDATE (),
--       IdTipoDdominio = 0,
--       IdTipoDominioDestino = 0,
--       IdTipoDDominioDestino = 0,
--       IdTipoSubOperacion = 59,
--       Salida = 0,
--       IdEstatusDominio = 1
--FROM dbo.tACTactivos a
--JOIN PaquetesPrecios g ON g.IdActivo = a.IdActivo
--WHERE NOT EXISTS (SELECT 1
--                  FROM dbo.tGRLoperacionesD dd
--                  WHERE dd.RelOperacionD = 1997353675 AND dd.IdActivo <> 0 AND dd.IdActivo = a.IdActivo);

--INSERT INTO dbo.tALMtransacciones(IdOperacionD, Fecha, Concepto, Referencia, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos,
--                                  IdProyecto, Costo, Precio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus)
--SELECT IdOperacionD,
--       Fecha = CURRENT_TIMESTAMP,
--       d.Concepto,
--       d.Referencia,
--       d.IdBienServicio,
--       d.IdActivo,
--       IdAlmacen = p.IdAlmacen,
--       d.IdDivision,
--       d.IdSucursal,
--       d.IdCentroCostos,
--       d.IdProyecto,
--       p.Costo,
--       p.Costo,
--       p.Costo,
--       p.Costo,
--       Cantidad = 1,
--       Salida = 1,
--       Existencia = 0,
--       IdEstatus = 1
--FROM dbo.tGRLoperacionesD d WITH(NOLOCK)
--INNER JOIN PaquetesPrecios p WITH(NOLOCK)ON p.IdActivo = d.IdActivo
--WHERE d.RelOperacionD = 1997353675

--UNION ALL

--SELECT IdOperacionD,
--       Fecha = CURRENT_TIMESTAMP,
--       d.Concepto,
--       d.Referencia,
--       d.IdBienServicio,
--       d.IdActivo,
--       IdAlmacen = 2,
--       d.IdDivision,
--       IdSucursal = 2,
--       d.IdCentroCostos,
--       d.IdProyecto,
--       p.Costo,
--       p.Costo,
--       p.Costo,
--       p.Costo,
--       Cantidad = 1,
--       Salida = 0,
--       Existencia = 1,
--       IdEstatus = 1
--FROM dbo.tGRLoperacionesD d WITH(NOLOCK)
--INNER JOIN PaquetesPrecios p WITH(NOLOCK)ON p.IdActivo = d.IdActivo
--WHERE d.RelOperacionD = 1997353675




SELECT * 
-- UPDATE tra SET tra.Entrada = 0
FROM dbo.tALMtransacciones tra
INNER JOIN dbo.tGRLoperacionesD opd ON opd.IdOperacionD = tra.IdOperacionD
WHERE opd.RelOperacionD = 1997353675 AND tra.Salida = 1