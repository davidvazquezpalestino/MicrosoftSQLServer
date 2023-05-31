INSERT INTO dbo.tACTactivos(IdBienServicio, Codigo, DescripcionLarga, IdSucursal, IdCentroCostos, IdProyecto, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdObservacionE, IdObservacionEDominio, IdSesion, Referencia, IdOperacionDorigen, IdClasificacionD, IdDivision, IdAlmacen, IdEstructuraContableE, DisponibleVenta, Costo, Precio)

SELECT DISTINCT act.IdBienServicio, t.[Codigo2], t.[DescripcionLarga], act.IdSucursal, act.IdCentroCostos, act.IdProyecto, act.IdEstatus, act.IdUsuarioAlta, GETDATE(), act.IdUsuarioCambio, GETDATE(), act.IdObservacionE, act.IdObservacionEDominio, act.IdSesion, act.Referencia, 0, 0, act.IdDivision, alm.IdAlmacen, act.IdEstructuraContableE, alm.DisponibleVenta, t.[Costo], t.Precio
FROM IERP_OBL.dbo.tmpMesada16 t
     JOIN dbo.tACTactivos act ON act.IdActivo=IdActivoPadre
     JOIN dbo.tALMalmacenes alm ON alm.IdAlmacen=act.IdAlmacen
WHERE IdActivoPadre != 0 AND NOT EXISTS (SELECT *
                                        FROM dbo.tACTactivos ac
                                        WHERE t.[Codigo2]=ac.Codigo COLLATE Modern_Spanish_CI_AI)
ORDER BY t.[Codigo2];

INSERT INTO dbo.tACTbienesAdjudicados(IdTipoDbienAdjudicado, IdTipoDformaAdjudicacion, FechaAdjudicacion, ValorRazonable, Estimacion, IdGarantia, IdEstatusEstimacion, IdEstatusBienAdjudicado, FechaUltimaEstimacion, IdActivo, IdCuenta, MontoPrestado, Avaluo, Capital, Ordinario, Moratorio, Impuestos, Paquete, porcentaje, Informacion, Peso)
SELECT bs.IdTipoDbienAdjudicado, bs.IdTipoDformaAdjudicacion, bs.FechaAdjudicacion, ROUND(t.Costo, 2), ROUND(bs.Estimacion * [t].[Porcentaje], 2), bs.IdGarantia, bs.IdEstatusEstimacion, bs.IdEstatusBienAdjudicado, bs.FechaUltimaEstimacion, ac.IdActivo, bs.IdCuenta, ROUND(bs.MontoPrestado * [t].[Porcentaje], 2), ROUND(bs.Avaluo * [t].[Porcentaje], 2), ROUND(bs.Capital * [t].[Porcentaje], 2), ROUND(bs.Ordinario * [t].[Porcentaje], 2), ROUND(bs.Moratorio * [t].[Porcentaje], 2), ROUND(bs.Impuestos * [t].[Porcentaje], 2), bs.Paquete, [t].[Porcentaje], '', t.[Peso]
FROM IERP_OBL.dbo.tmpMesada16 t
     JOIN dbo.tACTactivos ac ON t.[Codigo2]=ac.Codigo COLLATE Modern_Spanish_CI_AI
     JOIN dbo.tACTactivos padre ON padre.IdActivo=t.IdActivoPadre
     JOIN dbo.tACTbienesAdjudicados bs ON bs.IdActivo=padre.IdActivo
WHERE  NOT EXISTS (SELECT * FROM dbo.tACTbienesAdjudicados b WHERE b.IdActivo=ac.IdActivo);

INSERT INTO dbo.tALMtransacciones(IdOperacionD, Fecha, Concepto, Referencia, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, IdProyecto, Costo, Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus)

SELECT 0, GETDATE(), ac.Codigo+' SALIDA PAQUETE', 'MS-16', ac.IdBienServicio, ac.IdActivo, ac.IdAlmacen, ac.IdDivision, ac.IdSucursal, ac.IdCentroCostos, ac.IdProyecto, ac.Costo, ac.Precio, ac.Costo, ac.Costo, ac.Costo, 0, 1, 0, 1
FROM IERP_OBL.dbo.tmpMesada16 t
     JOIN dbo.tACTactivos ac ON ac.IdActivo=t.IdActivo AND IdActivoPadre=0 AND Porcentaje=1
WHERE 1=1 AND NOT EXISTS (SELECT *
                          FROM dbo.tALMtransacciones b
                          WHERE b.IdActivo=ac.IdActivo AND b.Concepto=ac.Codigo+' SALIDA PAQUETE' AND b.Referencia='MS-16')
UNION ALL
SELECT 0, GETDATE(), ac.Codigo+' ENTRADA PAQUETE', 'MS-16', ac.IdBienServicio, ac.IdActivo, ac.IdAlmacen, ac.IdDivision, ac.IdSucursal, ac.IdCentroCostos, ac.IdProyecto, ac.Costo, ac.Precio, ac.Costo, ac.Costo, ac.Costo, 1, 0, 1, 1
FROM IERP_OBL.dbo.tmpMesada16 t
     JOIN dbo.tACTactivos ac ON t.[Codigo2]=ac.Codigo COLLATE Modern_Spanish_CI_AI
WHERE NOT EXISTS (SELECT *
                  FROM dbo.tALMtransacciones b WITH(NOLOCK)
                  WHERE b.IdActivo=ac.IdActivo AND b.Concepto=ac.Codigo+' ENTRADA PAQUETE' AND b.Referencia='MS-16');

--ORDER BY 3
RETURN;

--INSERT INTO dbo.tALMtransacciones(IdOperacionD, Fecha, Concepto, Referencia, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, IdProyecto, Costo, Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus)
--SELECT 0, GETDATE(), ac.Codigo+' SALIDA B.A.', 'MS-16', ac.IdBienServicio, ac.IdActivo, ac.IdAlmacen, ac.IdDivision, ac.IdSucursal, ac.IdCentroCostos, ac.IdProyecto, ac.Costo, ac.Costo, ac.Costo, ac.Costo, ac.Costo, 0, 1, 0, 1
--FROM IERP_OBL.dbo.tmpMesada16 t
--JOIN dbo.tACTactivos ac ON t.[Codigo2]=ac.Codigo COLLATE Modern_Spanish_CI_AI
--WHERE IdActivoPadre=0 AND NOT EXISTS (SELECT *
--                                      FROM dbo.tALMtransacciones b
--                                      WHERE b.IdActivo=ac.IdActivo AND b.Concepto=ac.Codigo+' SALIDA B.A.' AND b.Referencia='MS-16')
--UNION ALL
--SELECT 0, GETDATE(), ac.Codigo+' ENTRADA B.A.', 'MS-16', ac.IdBienServicio, ac.IdActivo, IdAlmacen=2, ac.IdDivision, ac.IdSucursal, ac.IdCentroCostos, ac.IdProyecto, ac.Costo, t.Precio, ac.Costo, ac.Costo, ac.Costo, 1, 0, 1, 1
--FROM IERP_OBL.dbo.tmpMesada16 t
--JOIN dbo.tACTactivos ac ON t.IdActivo=ac.IdActivo AND NOT EXISTS (SELECT *
--                                                                       FROM dbo.tALMtransacciones b
--                                                                       WHERE b.IdActivo=ac.IdActivo AND b.Concepto=ac.Codigo+' ENTRADA B.A.' AND b.Referencia='MS-16')
--ORDER BY 3 DESC;

--SELECT  ac.Costo, ac.Precio, t.Precio, ac.DisponibleVenta, ac.DescripcionLarga, t.[DescripcionLarga], ac.IdSucursal, *
---- update ac set Precio = t.precio,  costo = iif(ac.costo<t.costo, t.costo, ac.costo)
--FROM   iERP_OBL.dbo.tmpMesada16 t
--JOIN dbo.tACTactivos ac ON t.IdActivo = ac.IdActivo
--WHERE  ac.Precio != t.Precio AND idactivopadre = 0

--SELECT  ac.Costo, ac.Precio, t.Precio, ac.DisponibleVenta, ac.DescripcionLarga, t.[DescripcionLarga], ac.IdSucursal, *
---- update ac set Precio = t.precio,  costo = iif(ac.costo<t.costo, t.costo, ac.costo)
--FROM   iERP_OBL.dbo.tmpMesada16 t
--JOIN dbo.tACTactivos ac ON ac.codigo = t.codigo2
--WHERE idactivopadre != 0
