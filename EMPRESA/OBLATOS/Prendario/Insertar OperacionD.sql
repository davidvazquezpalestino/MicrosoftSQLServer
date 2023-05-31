USE IERP_OBL ;
GO

 -- BEGIN TRANSACTION ;
 -- COMMIT TRANSACTION 
	
DECLARE @IdOperacionPadre INT = 2030130500;
DECLARE @IdCuenta INT = 1407015 ;

DECLARE @FechaTrabajo DATE ;

SELECT @FechaTrabajo = Fecha
FROM dbo.tGRLoperaciones WITH( NOLOCK )
WHERE IdOperacion = @IdOperacionPadre ;

DROP TABLE IF EXISTS #tmpACTcuentas ;
CREATE TABLE #tmpACTcuentas
(
idOperacion INT NOT NULL DEFAULT 0,
fechaAdjudicacion DATE NOT NULL DEFAULT '19000101',
idsucursal INT NOT NULL DEFAULT 0,
idalmacen INT NOT NULL DEFAULT 0,
idactivo INT NOT NULL DEFAULT 0,
idgarantia INT NOT NULL DEFAULT 0,
idcuenta INT NOT NULL DEFAULT 0,
idSocio INT NOT NULL DEFAULT 0,
MontoPrestadoCuenta NUMERIC(18, 2) NOT NULL DEFAULT 0,
MontoTotalGarantia NUMERIC(18, 2) NOT NULL DEFAULT 0,
capital NUMERIC(18, 2) NOT NULL DEFAULT 0,
Ordinario NUMERIC(18, 2) NOT NULL DEFAULT 0,
Moratorio NUMERIC(18, 2) NOT NULL DEFAULT 0,
impuestos NUMERIC(18, 2) NOT NULL DEFAULT 0,
total NUMERIC(18, 2) NOT NULL DEFAULT 0,
diasMora INT NOT NULL DEFAULT 0,
Ajuste NUMERIC(18, 2) NOT NULL DEFAULT 0,
idGarantiaAjuste INT NOT NULL DEFAULT 0
) ;

DROP TABLE IF EXISTS #tmpACTtabla ;
CREATE TABLE #tmpACTtabla
(
IdBienServicio INT NOT NULL DEFAULT 0,
IdActivo INT NOT NULL DEFAULT '',
Codigo VARCHAR(30) NOT NULL DEFAULT '',
DescripcionLarga VARCHAR(500) NOT NULL DEFAULT '',
IdSucursal INT NOT NULL DEFAULT 0,
IdCentroCostos INT NOT NULL DEFAULT 0,
IdProyecto INT NOT NULL DEFAULT 0,
IdEstatus INT NOT NULL DEFAULT 0,
Referencia VARCHAR(30) NOT NULL DEFAULT '',
paquete VARCHAR(128) NOT NULL DEFAULT '',
IdOperacionDorigen INT NOT NULL DEFAULT 0,
IdClasificacionD INT NOT NULL DEFAULT 0,
IdDivision INT NOT NULL DEFAULT 0,
IdAlmacen INT NOT NULL DEFAULT 0,
IdEstructuraContableE INT NOT NULL DEFAULT 0,
IdBienAdjudicado INT NOT NULL DEFAULT 0,
IdTipoDbienAdjudicado INT NOT NULL DEFAULT 0,
IdTipoDformaAdjudicacion INT NOT NULL DEFAULT 0,
FechaAdjudicacion DATE NOT NULL DEFAULT '19000101',
Costo NUMERIC(18, 2) NOT NULL DEFAULT 0,
MontoPrestado NUMERIC(18, 2) NOT NULL DEFAULT 0,
porcentaje NUMERIC(23, 18) NOT NULL DEFAULT 0,
MontoPrestadoReal NUMERIC(18, 2) NOT NULL DEFAULT 0,
MontoCapital NUMERIC(18, 2) NOT NULL DEFAULT 0,
Avaluo NUMERIC(18, 2) NOT NULL DEFAULT 0,
Capital NUMERIC(18, 2) NOT NULL DEFAULT 0,
Ordinario NUMERIC(18, 2) NOT NULL DEFAULT 0,
Moratorio NUMERIC(18, 2) NOT NULL DEFAULT 0,
Impuestos NUMERIC(18, 2) NOT NULL DEFAULT 0,
ValorRazonable NUMERIC(18, 2) NOT NULL DEFAULT 0,
Estimacion NUMERIC(18, 2) NOT NULL DEFAULT 0,
IdGarantia INT NOT NULL DEFAULT 0,
IdEstatusEstimacion INT NOT NULL DEFAULT 0,
IdEstatusBienAdjudicado INT NOT NULL DEFAULT 0,
FechaUltimaEstimacion DATE NOT NULL DEFAULT '19000101',
Cantidad INT NOT NULL DEFAULT 0,
IdAuxiliar INT NOT NULL DEFAULT 0,
IdCuenta INT NOT NULL DEFAULT 0
) ;

INSERT INTO #tmpACTcuentas( idcuenta, idsucursal, idSocio, fechaAdjudicacion, capital, Ordinario, Moratorio, impuestos, total )
SELECT Transaccion.IdCuenta,
       Operacion.IdSucursal,
       Operacion.IdSocio,
       Transaccion.Fecha,
       CapitalPagado = ISNULL (Transaccion.CapitalPagado, 0) + ISNULL (Transaccion.CapitalPagadoVencido, 0),
       InteresOrdinarioPagado = ISNULL (Transaccion.InteresOrdinarioPagado, 0) + ISNULL (Transaccion.InteresOrdinarioPagadoVencido, 0),
       InteresMoratorioPagado = ISNULL (Transaccion.InteresMoratorioPagado, 0) + ISNULL (Transaccion.InteresMoratorioPagadoVencido, 0),
       IVAPagado = ISNULL (Transaccion.IVAInteresOrdinarioPagado, 0) + ISNULL (Transaccion.IVAInteresMoratorioPagado, 0),
       Transaccion.TotalPagado
FROM dbo.tSDOtransaccionesFinancieras Transaccion WITH( NOLOCK )
INNER JOIN dbo.tGRLoperaciones Operacion WITH( NOLOCK )ON Operacion.IdOperacion = Transaccion.IdOperacion
WHERE Transaccion.IdEstatus = 1 AND Operacion.IdOperacionPadre = @IdOperacionPadre AND Transaccion.IdCuenta = @IdCuenta ;



INSERT INTO #tmpACTtabla( IdCuenta, IdBienServicio, Codigo, DescripcionLarga, IdSucursal, IdCentroCostos, IdProyecto, IdEstatus, Referencia, paquete, IdOperacionDorigen, IdClasificacionD, IdDivision, IdAlmacen, IdEstructuraContableE, IdBienAdjudicado, IdTipoDbienAdjudicado, IdTipoDformaAdjudicacion, FechaAdjudicacion, porcentaje, MontoPrestadoReal, ValorRazonable, Estimacion, IdGarantia, IdEstatusEstimacion, IdEstatusBienAdjudicado, FechaUltimaEstimacion, Cantidad, IdAuxiliar, MontoPrestado, MontoCapital, Avaluo, Capital, Ordinario, Moratorio, Impuestos )
SELECT c.IdCuenta,
       IdBienServicio = CASE WHEN c.EsPrendario = 1 THEN
                                  -2016
                             WHEN g.IdTipoD = 442 THEN
                                  -2010
                             WHEN g.IdTipoD = 769 THEN
                                  -2009
                             ELSE 0
                        END,
       Codigo = CONCAT ('B.ADJ-AD-2', RIGHT(CONCAT ('0000000000', g.IdGarantia), 10)),
       DescripcionLarga = g.DescripcionLarga,
       cta.idsucursal,
       s.IdCentroCostos,
       IdProyecto = 0,
       IdEstatus = 1,
       Referencia = c.Codigo,
       g.Paquete,
       IdOperacionDorigen = 0,
       IdClasificacionD = 0,
       IdDivision = CASE WHEN c.EsPrendario = 1 THEN
                              -42
                         WHEN g.IdTipoD = 442 THEN
                              -39
                         WHEN g.IdTipoD = 769 THEN
                              -38
                         ELSE 0
                    END,
       IdAlmacen = 1,
       IdEstructuraContableE = -14,
       IdBienAdjudicado = 0,
       IdTipoDbienAdjudicado = CASE WHEN g.IdTipoD = 442 THEN
                                         2224
                                    WHEN g.IdTipoD = 769 THEN
                                         2225
                                    ELSE 0
                               END,
       IdTipoDformaAdjudicacion = 2274,
       FechaAdjudicacion = @FechaTrabajo,
       porcentaje = 0,
       MontoPrestadoReal = 0,
       ValorRazonable = cta.total,
       Estimacion = 0,
       g.IdGarantia,
       IdEstatusEstimacion = 24,
       IdEstatusBienAdjudicado = 1,
       FechaUltimaEstimacion = CAST('19000101' AS DATE),
       Cantidad = 1,
       IdAuxiliar = 0,
       MontoPrestado = g.MontoPrestado,
       MontoCapital = g.Capital,
       Avaluo = g.MontoOriginal,
       Capital = 0,
       Ordinarios = 0,
       Moratorios = 0,
       Impuestos = 0
FROM dbo.tAYCcuentas c WITH( NOLOCK )
JOIN #tmpACTcuentas cta ON cta.idcuenta = c.IdCuenta
JOIN( SELECT g.IdGarantia,
             d.IdTipoD,
             g.MontoOriginal,
             g.Monto,
             g.MontoPrestado,
             g.RelGarantias,
             g.Capital,
             DescripcionLarga = RTRIM (LTRIM (CONCAT (UPPER (g.Referencia), ' ', mtl.Codigo, ' ', vari.Codigo))),
             g.Paquete
      FROM dbo.tAYCgarantias g WITH( NOLOCK )
      JOIN dbo.tCTLtiposD d WITH( NOLOCK )ON d.IdTipoD = g.IdTipoD
      JOIN dbo.tCATlistasD mtl WITH( NOLOCK )ON mtl.IdListaD = g.IdListaDsubTipo
      JOIN dbo.tCATlistasD vari WITH( NOLOCK )ON vari.IdListaD = g.IdListaDvariedad ) AS g ON g.RelGarantias = c.IdCuenta
JOIN dbo.tCTLsucursales s WITH( NOLOCK )ON s.IdSucursal = c.IdSucursal
WHERE c.IdTipoDProducto = 143 AND g.IdTipoD IN (442, 860) AND c.IdEstatus IN (1, 7) AND c.IdCuenta = @IdCuenta ;

--CALCULAMOS EL TOTAL DE LAS GARANTIAS
UPDATE cta
SET MontoTotalGarantia = gr.MontoTotalGarantia
FROM #tmpACTcuentas cta
JOIN( SELECT IdCuenta,
             MontoTotalGarantia = SUM (MontoPrestado)
      FROM #tmpACTtabla
      GROUP BY IdCuenta ) AS gr ON gr.idcuenta = cta.idcuenta ;

--CALCULAMOS EL PORCENTAJE DE LAS CUENTAS
UPDATE tbl
SET porcentaje = ( tbl.MontoPrestado / cta.MontoTotalGarantia )
FROM #tmpACTtabla tbl
JOIN #tmpACTcuentas cta ON cta.idcuenta = tbl.IdCuenta ;

UPDATE tbl
SET porcentaje = tbl.MontoPrestado / cta.MontoTotalGarantia,
    MontoPrestadoReal = ROUND (cta.MontoPrestadoCuenta * tbl.porcentaje, 2),
    Capital = ROUND (cta.capital * tbl.porcentaje, 2),
    Ordinario = ROUND (cta.Ordinario * tbl.porcentaje, 2),
    Moratorio = ROUND (cta.Moratorio * tbl.porcentaje, 2),
    Impuestos = ROUND (cta.impuestos * tbl.porcentaje, 2)
FROM #tmpACTtabla tbl
JOIN #tmpACTcuentas cta ON cta.idcuenta = tbl.IdCuenta ;

-- ACTAULIZAMOS EL ALMACEN
UPDATE t
SET IdAlmacen = alm.IdAlmacen
FROM #tmpACTtabla t
JOIN( SELECT IdSucursal,
             IdAlmacen,
             Numero = ROW_NUMBER () OVER ( PARTITION BY IdSucursal
                                           ORDER BY IdAlmacen )
      FROM dbo.tALMalmacenes WITH( NOLOCK )
      WHERE EsAdjudicacion = 1 ) alm ON alm.IdSucursal = t.IdSucursal AND Numero = 1 ;


PRINT 'CALCULAMOS EL COSTO DE CADA ACTIVO' ;
-- Generamos el costo de cada activo sumando su parte de la cuenta de cada rubro
UPDATE #tmpACTtabla
SET Costo = ROUND (( Capital + Ordinario + Moratorio + Impuestos ), 2) ;

-- Calculamos el ajuste por todas las garantias
UPDATE cta
SET idgarantia = tmp.idgarantia,
    Ajuste = ( cta.total - tmp.total )
FROM #tmpACTcuentas cta
JOIN( SELECT IdCuenta,
             IdGarantia = MIN (IdGarantia),
             total = SUM (Capital + Ordinario + Moratorio + Impuestos)
      FROM #tmpACTtabla
      GROUP BY IdCuenta ) AS tmp ON tmp.idcuenta = cta.idcuenta ;

--Actualizamos en la primera garantia
UPDATE tl
SET tl.Costo = ( tl.Costo + cta.Ajuste )
FROM #tmpACTcuentas cta
JOIN #tmpACTtabla tl ON tl.IdGarantia = cta.idGarantiaAjuste
WHERE cta.Ajuste <> 0 ;

PRINT 'AFECTAMOS EL ACTIVO' ;
INSERT INTO dbo.tACTactivos( IdBienServicio, Codigo, DescripcionLarga, IdSucursal, IdCentroCostos, IdProyecto, IdEstatus, IdUsuarioAlta, Alta, Referencia, IdOperacionDorigen, IdClasificacionD, IdDivision, IdAlmacen, IdEstructuraContableE, DisponibleVenta, Costo, Precio, IdUsuarioCambio, IdObservacionE, IdObservacionEDominio, IdSesion, IdOperacion )
SELECT IdBienServicio,
       Codigo,
       DescripcionLarga,
       IdSucursal,
       IdCentroCostos,
       IdProyecto,
       IdEstatus,
       IdUsuario = -1,
       GETDATE (),
       Referencia,
       IdOperacionD = 0,
       IdClasificacionD = 0,
       IdDivision,
       IdAlmacen,
       IdEstructuraContableE,
       DisponibleVenta = 0,
       Costo,
       Costo,
       0,
       0,
       0,
       0,
	   @IdOperacionPadre
FROM #tmpACTtabla ;

UPDATE t
SET IdActivo = act.IdActivo
FROM #tmpACTtabla t
JOIN dbo.tACTactivos act ON act.IdBienServicio = t.IdBienServicio AND act.Codigo COLLATE DATABASE_DEFAULT = t.Codigo COLLATE DATABASE_DEFAULT ;

PRINT 'ADJUDICADOS' ;

INSERT INTO dbo.tACTbienesAdjudicados( IdTipoDbienAdjudicado, IdTipoDformaAdjudicacion, FechaAdjudicacion, ValorRazonable, Estimacion, IdGarantia, IdEstatusEstimacion, IdEstatusBienAdjudicado, FechaUltimaEstimacion, IdActivo, MontoPrestado, Avaluo, Capital, Ordinario, Moratorio, Impuestos, Paquete, IdCuenta )
SELECT t.IdTipoDbienAdjudicado,
       t.IdTipoDformaAdjudicacion,
       t.FechaAdjudicacion,
       t.ValorRazonable,
       t.Estimacion,
       t.IdGarantia,
       t.IdEstatusEstimacion,
       t.IdEstatusBienAdjudicado,
       t.FechaUltimaEstimacion,
       t.IdActivo,
       t.MontoPrestado,
       Avaluo,
       t.Capital,
       Ordinario,
       Moratorio,
       Impuestos,
       paquete,
       IdCuenta
FROM #tmpACTtabla t ;

PRINT 'AFECTAMOS LA OPERACIÓN D' ;
INSERT INTO dbo.tGRLoperacionesD( RelOperacionD, IdOperacionDOrigen, Partida, IdActivo, IdBienServicio, DescripcionBienServicio, Concepto, Referencia, IdDivision, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdAlmacen, Cantidad, Subtotal, Total, Costo, CostoTotal, IdSucursal, IdEstructuraContableE, IdEstatus, IdCentroCostos, IdSesion, IdUsuarioAlta, Alta, IdTipoDdominio, IdTipoDDominioDestino, IdTipoSubOperacion, Salida, IdEstatusDominio )
SELECT RelOperacionD = @IdOperacionPadre,
       IdOperacionDorigen = 0,
       1,
       t.IdActivo,
       t.IdBienServicio,
       t.DescripcionLarga,
       Concepto = 'ADJUDICACIÓN',
       t.Referencia,
       t.IdDivision,
       t.IdProyecto,
       t.IdAuxiliar,
       IdEntidad1 = 0,
       IdEntidad2 = 0,
       IdEntidad3 = 0,
       t.IdAlmacen,
       t.Cantidad,
       t.Costo,
       t.Costo,
       t.Costo,
       t.Costo,
       t.IdSucursal,
       t.IdEstructuraContableE,
       t.IdEstatus,
       t.IdCentroCostos,
       IdSesion = 0,
       IdUsuarioAlta = -1,
       GETDATE (),
       IdTipoDdominio = 2249,
       IdTipoDDominioDestino = 2249,
       IdTipoSubOperacion = 38,
       Salida = 0,
       IdEstatusDominio = 1
FROM #tmpACTtabla t ;


PRINT 'AFECTAMOS EL ALMACEN' ;
INSERT INTO dbo.tALMtransacciones( IdOperacionD, Fecha, Concepto, Referencia, IdBienServicio, IdActivo, IdAlmacen, IdDivision, IdSucursal, IdCentroCostos, IdProyecto, Costo, Precio, CostoTotal, ImporteTotal, Entrada, Salida, Existencia, IdEstatus )
SELECT d.IdOperacionD,
       @FechaTrabajo,
       d.Concepto,
       d.Referencia,
       d.IdBienServicio,
       d.IdActivo,
       d.IdAlmacen,
       d.IdDivision,
       d.IdSucursal,
       d.IdCentroCostos,
       d.IdProyecto,
       d.Costo,
       d.Costo,
       d.Costo,
       d.Costo,
       d.Cantidad,
       Salida = 0,
       Existencia = 0,
       IdEstatus = 1
FROM dbo.tGRLoperacionesD d WITH( NOLOCK )
WHERE d.RelOperacionD = @IdOperacionPadre ;

PRINT 'AFECTAMOS LA ESTADISTICA ADJUDICACIÓN' ;
IF NOT EXISTS ( SELECT 1
                FROM dbo.tAYCcuentasEstadisticasAdjudicacion
                WHERE IdCuenta = @IdCuenta )
BEGIN
    INSERT INTO dbo.tAYCcuentasEstadisticasAdjudicacion( IdCuenta, IdOperacion, Fecha, IdPeriodo, Capital, InteresOrdinario, InteresMoratorio, IVA, AplicaPenalizacion )
    SELECT cta.idcuenta,
           cta.idOperacion,
           cta.fechaAdjudicacion,
           dbo.fGETidPeriodo (cta.fechaAdjudicacion),
           cta.capital,
           cta.Ordinario,
           cta.Moratorio,
           cta.impuestos,
           1
    FROM #tmpACTcuentas cta ;
END ;

EXECUTE dbo.pIMPgenerarTransaccionesImpuestos @IdOperacionPadre = @IdOperacionPadre ;

