
UPDATE a SET IdActivoPadre = b.IdActivo, a.IdActivo = 0, Costo = CAST(a.Costo AS DECIMAL(18, 2)), Peso = CAST(a.Peso AS decimal (18, 2)), Porcentaje = CAST(a.Porcentaje AS DECIMAL (18, 2))
FROM ##PaquetesPrecios a
INNER JOIN dbo.tACTactivos b ON b.Codigo = a.CodigoGarantia COLLATE DATABASE_DEFAULT
WHERE PATINDEX('%-ART%', codigoparte) > 0;

UPDATE a SET IdActivoPadre = 0, a.IdActivo = b.IdActivo 
FROM ##PaquetesPrecios a
INNER JOIN dbo.tACTactivos b ON b.Codigo = a.CodigoGarantia COLLATE DATABASE_DEFAULT
WHERE PATINDEX('%-ART%', codigoparte) = 0;


INSERT INTO dbo.tACTactivos(IdBienServicio, Codigo, DescripcionLarga, IdSucursal, IdCentroCostos, IdProyecto, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, IdSesion, IdObservacionE, IdObservacionEDominio, Referencia, IdOperacionDorigen, IdClasificacionD, IdDivision, IdAlmacen, IdEstructuraContableE, DisponibleVenta, Costo, Precio, Observaciones)
SELECT activo.IdBienServicio, CodigoParte, DescripcionParte = LTRIM(RTRIM(DescripcionParte)), activo.IdSucursal, activo.IdCentroCostos, activo.IdProyecto, activo.IdEstatus, IdUsuarioAlta, Alta = CURRENT_TIMESTAMP, IdUsuarioCambio, IdSesion, IdObservacionE, IdObservacionEDominio, Referencia, IdOperacionDorigen, IdClasificacionD, IdDivision, IdAlmacen, IdEstructuraContableE, DisponibleVenta, Costo = ROUND(paquete.Costo, 2), paquete.PrecioVenta, Observaciones = 'M17'
FROM ##PaquetesPrecios paquete
INNER JOIN dbo.tACTactivos activo ON activo.IdActivo = IdActivoPadre 
WHERE IdActivoPadre > 0 AND NOT EXISTS (SELECT 1 FROM dbo.tACTactivos a WHERE a.Codigo = paquete.CodigoParte COLLATE DATABASE_DEFAULT )


INSERT INTO dbo.tACTbienesAdjudicados(IdTipoDbienAdjudicado, IdTipoDformaAdjudicacion, FechaAdjudicacion, ValorRazonable, Estimacion, IdGarantia, IdEstatusEstimacion, IdEstatusBienAdjudicado, FechaUltimaEstimacion, IdActivo, IdCuenta, MontoPrestado, Avaluo, Capital, Ordinario, Moratorio, Impuestos, Paquete, porcentaje, Informacion, Peso)
SELECT bs.IdTipoDbienAdjudicado, bs.IdTipoDformaAdjudicacion, bs.FechaAdjudicacion, ROUND(t.Costo, 2), ROUND(bs.Estimacion * [t].[Porcentaje], 2), bs.IdGarantia, bs.IdEstatusEstimacion, bs.IdEstatusBienAdjudicado, bs.FechaUltimaEstimacion, act.IdActivo, bs.IdCuenta, ROUND(bs.MontoPrestado * [t].[Porcentaje], 2), ROUND(bs.Avaluo * [t].[Porcentaje], 2), ROUND(bs.Capital * [t].[Porcentaje], 2), ROUND(bs.Ordinario * [t].[Porcentaje], 2), ROUND(bs.Moratorio * [t].[Porcentaje], 2), ROUND(bs.Impuestos * [t].[Porcentaje], 2), bs.Paquete, [t].[Porcentaje], '', t.[Peso]
FROM ##PaquetesPrecios t   
INNER JOIN dbo.tACTactivos act ON act.Codigo = CodigoParte COLLATE DATABASE_DEFAULT
INNER JOIN dbo.tACTbienesAdjudicados bs ON bs.IdActivo = t.IdActivoPadre
WHERE  NOT EXISTS (SELECT 1 FROM dbo.tACTbienesAdjudicados b WHERE b.IdActivo = act.IdActivo);

INSERT INTO dbo.tALMtransacciones(IdOperacionD, Fecha, Concepto, Referencia, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, IdProyecto, Costo, Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus)
SELECT IdOperacionD = 0, Fecha = CURRENT_TIMESTAMP, CONCAT('SALIDA PAQUETE ', activo.Codigo), Referencia = 'MS-17', activo.IdBienServicio, activo.IdActivo, activo.IdAlmacen, activo.IdDivision, activo.IdSucursal, activo.IdCentroCostos, activo.IdProyecto, activo.Costo, activo.Precio, CostoPromedio, CostoTotal, ImporteTotal, Entrada = 0, Salida = 1, Existencia, activo.IdEstatus
FROM ##PaquetesPrecios a
INNER JOIN dbo.tACTactivos activo ON a.IdActivo = activo.IdActivo
INNER JOIN dbo.tALMtransacciones Transaccion ON Transaccion.IdActivo = a.IdActivo
WHERE a.IdActivo > 0

UNION ALL

SELECT IdOperacionD = 0, Fecha = CURRENT_TIMESTAMP, CONCAT('ENTRADA ', activo.Codigo), Referencia = 'MS-17', activo.IdBienServicio, activo.IdActivo, activo.IdAlmacen, activo.IdDivision, activo.IdSucursal, activo.IdCentroCostos, IdProyecto, activo.Costo, activo.Precio, 0, 0, 0, Entrada = 1, Salida = 0, 0, activo.IdEstatus
FROM ##PaquetesPrecios paquete
INNER JOIN dbo.tACTactivos activo ON activo.Codigo = CodigoParte COLLATE DATABASE_DEFAULT
WHERE IdActivoPadre > 0

SELECT a.*
-- UPDATE b SET b.Precio = PrecioVenta, IdAlmacen = 2, b.DisponibleVenta = 1
FROM ##PaquetesPrecios a
LEFT JOIN dbo.tACTactivos b ON b.Codigo = CASE WHEN PATINDEX( '%-ART%', CodigoParte ) > 0 THEN CodigoParte ELSE  a.CodigoGarantia COLLATE DATABASE_DEFAULT END
