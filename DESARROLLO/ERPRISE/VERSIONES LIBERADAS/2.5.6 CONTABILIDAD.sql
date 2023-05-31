
IF NOT EXISTS(SELECT IdTipoOperacion FROM dbo.tCTLtiposOperacion  WHERE IdTipoOperacion =  541) 	
BEGIN
	INSERT INTO dbo.tCTLtiposOperacion (IdTipoOperacion, IdTipoDdominio, Codigo, Descripcion, DescripcionLarga, UsaSeries, IdAsiento, IdListaDpoliza, IdAgrupadorSaldo, IdEstatus, AplicaMovimientoIntersucursal, IdAuxiliar, AfectarAuxiliarRetenciones, EsOperacionUsuario, SerieDefault, Naturaleza, IdTipoDingresoGasto, NaturalezaInventario) 
	VALUES (541, 2477, 'APLNCC', 'APLICACION NOTA CXC', 'APLICACION NOTA DE CREDITO CLIENTE', 0, 0, 0, 0, 1, 0, -23, 0, 0, '', 0, 0, 0) 
END 
IF NOT EXISTS(SELECT IdTipoOperacion FROM dbo.tCTLtiposOperacion  WHERE IdTipoOperacion =  542) 	
BEGIN
	INSERT INTO dbo.tCTLtiposOperacion (IdTipoOperacion, IdTipoDdominio, Codigo, Descripcion, DescripcionLarga, UsaSeries, IdAsiento, IdListaDpoliza, IdAgrupadorSaldo, IdEstatus, AplicaMovimientoIntersucursal, IdAuxiliar, AfectarAuxiliarRetenciones, EsOperacionUsuario, SerieDefault, Naturaleza, IdTipoDingresoGasto, NaturalezaInventario) 
	VALUES (542, 2663, 'APLNCP', 'APLICACION NOTA CXP', 'APLICACION NOTA DE CREDITO PROVEEDOR', 0, 0, 0, 0, 1, 0, -71, 0, 0, '', 0, 0, 0) 
END 

IF NOT EXISTS(SELECT IdAsientoD FROM dbo.tCNTasientosD WHERE IdTipoDDominio =  141 AND IdTipoOperacion = 541 AND IdTipoDRubro = 2725) 
BEGIN
	INSERT INTO dbo.tCNTasientosD(IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias) 
	VALUES ( 1, 1, 3, 141, 2725, 'CuentaOrden', 'Valor', 0, 0, 0, 541, 0, 1, 0, 'Valor') 
END
IF NOT EXISTS(SELECT IdAsientoD FROM dbo.tCNTasientosD WHERE IdTipoDDominio =  141 AND IdTipoOperacion = 541 AND IdTipoDRubro = 2726) 
BEGIN
	INSERT INTO dbo.tCNTasientosD(IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias) 
	VALUES (1, 1, 3, 141, 2726, 'CuentaOrden', 'Valor', 1, 0, 0, 541, 0, 1, 0, 'Valor') 
END
IF NOT EXISTS(SELECT IdAsientoD FROM dbo.tCNTasientosD WHERE IdTipoDDominio =  1575 AND IdTipoOperacion = 542 AND IdTipoDRubro = 2727) 
BEGIN
	INSERT INTO dbo.tCNTasientosD(IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias) 
	VALUES (1, 1, 3, 1575, 2727, 'CuentaOrden', 'Valor', 0, 0, 0, 542, 0, 1, 0, 'Valor') 
END
IF NOT EXISTS(SELECT IdAsientoD FROM dbo.tCNTasientosD WHERE IdTipoDDominio =  1575 AND IdTipoOperacion = 542 AND IdTipoDRubro = 2728) 
BEGIN	
	INSERT INTO dbo.tCNTasientosD(IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias) 
	VALUES (1, 1, 3, 1575, 2728, 'CuentaOrden', 'Valor', 1, 0, 0, 542, 0, 1, 0, 'Valor') 
END

IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='tGRLOperacionesCuentasOrden' AND COLUMN_NAME= 'IdOperacionD')
ALTER TABLE dbo.tGRLOperacionesCuentasOrden ADD IdOperacionD INT NOT NULL DEFAULT 0

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  18/09/2021
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pIMPgenerarOperacionesDIngresosGastosPagados'))
DROP PROCEDURE pIMPgenerarOperacionesDIngresosGastosPagados
GO

CREATE PROCEDURE dbo.pIMPgenerarOperacionesDIngresosGastosPagados
@IdOperacion INT = NULL
AS
-- 
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    INSERT INTO dbo.tGRLOperacionesCuentasOrden(IdOperacion, IdOperacionD, IdTipoDdominio, IdTipoOperacion, IdEstatusDominio, Valor, BaseIVA, IVA, TasaIVA, TasaRetencionIVA, TasaRetencionISR, Concepto, Referencia, IdPersona, IdSocio, IdCuenta, IdBienServicio, IdCentroCostos, IdDivision, IdProyecto, IdAlmacen, IdCuentaABCD, IdDivisa, IdEntidad1, IdEntidad2, IdEntidad3, IdActivo, IdImpuesto, IdSucursal, IdEstructuraContableE)
    SELECT Transaccion.IdOperacion,
        Partida.IdOperacionD,
        Partida.IdTipoDDominioDestino,
        IdTipoOperacion = CASE WHEN Transaccion.IdTipoDDominioDestino = 136 AND Transaccion.IdAuxiliar = -21 THEN 538 -- APLICACION DE FACTURA
                               WHEN Transaccion.IdTipoDDominioDestino = 136 AND Transaccion.IdAuxiliar = -23 THEN 541 -- APLICACION DE NOTA CREDITO (CXC)
                               WHEN Transaccion.IdTipoDDominioDestino = 137 AND Transaccion.IdAuxiliar = -30 THEN 539 -- APLICACION CUENTA POR PAGAR
                               WHEN Transaccion.IdTipoDDominioDestino = 137 AND Transaccion.IdAuxiliar = -71 THEN 542 -- APLICACION NOTA DE CRÉDITO (CXP)
                               WHEN Transaccion.IdTipoDDominioDestino = 700 THEN 539
                               ELSE NULL
                          END,
        Partida.IdEstatusDominio,
        Valor = Partida.Subtotal * CASE Saldo.SubTotalGenerado WHEN 0 THEN 1
                                                               ELSE Transaccion.SubTotalPagado / Saldo.SubTotalGenerado
                                   END,
        BaseIVA = Partida.Subtotal * CASE Saldo.SubTotalGenerado WHEN 0 THEN 1
                                                                 ELSE Transaccion.SubTotalPagado / Saldo.SubTotalGenerado
                                     END,
        IVA = Partida.IVA * CASE Saldo.SubTotalGenerado WHEN 0 THEN 1
                                                        ELSE (Transaccion.SubTotalPagado / Saldo.SubTotalGenerado)
                            END,
        Impuesto.TasaIVA,
        Impuesto.TasaRetencionIVA,
        Impuesto.TasaRetencionISR,
        Partida.Concepto,
        Partida.Referencia,
        Saldo.IdPersona,
        Saldo.IdSocio,
        Saldo.IdCuenta,
        Partida.IdBienServicio,
        Partida.IdCentroCostos,
        Partida.IdDivision,
        Partida.IdProyecto,
        Partida.IdAlmacen,
        Saldo.IdCuentaABCD,
        Transaccion.IdDivisa,
        Partida.IdEntidad1,
        Partida.IdEntidad2,
        Partida.IdEntidad3,
        Partida.IdActivo,
        Partida.IdImpuesto,
        Partida.IdSucursal,
        Partida.IdEstructuraContableE
    FROM dbo.tSDOtransacciones Transaccion WITH(NOLOCK)
    INNER JOIN dbo.tSDOsaldos Saldo WITH(NOLOCK)ON Saldo.IdSaldo = Transaccion.IdSaldoDestino AND Transaccion.IdTipoSubOperacion = 502
    INNER JOIN dbo.tGRLoperaciones OperacionFactura WITH(NOLOCK)ON OperacionFactura.IdOperacion = Saldo.IdOperacion
    INNER JOIN dbo.tGRLoperacionesD Partida WITH(NOLOCK)ON OperacionFactura.IdOperacion = Partida.RelOperacionD
    INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Partida.IdImpuesto
    WHERE Saldo.IdTipoDDominioCatalogo <> 700 AND Transaccion.IdEstatus = 1 AND OperacionFactura.IdOperacion <> 0 AND Transaccion.IdOperacion = @IdOperacion AND NOT EXISTS (SELECT 1 FROM dbo.tGRLOperacionesCuentasOrden CuentaOrden WITH(NOLOCK) WHERE Transaccion.IdOperacion = CuentaOrden.IdOperacion);
END;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  18/09/2021
=============================================*/
IF EXISTS (SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vCNToperacionesD'))
    DROP VIEW dbo.vCNToperacionesD;
GO


CREATE VIEW [dbo].[vCNToperacionesD]
AS
-- se quitan campos que no se requieren
SELECT OperacionD.IdOperacionD,
    OperacionD.RelOperacionD,
    OperacionD.IdTipoDDominioDestino,
    OperacionD.IdBienServicio,
    IdTipoSubOperacion = TipoOperacion.IdTipoOperacion,
    OperacionD.IdTipoDominioOrigen,
    OperacionD.IdTipoDominioDestino,
    OperacionD.IdCentroCostos,
    OperacionD.IdSucursal,
    OperacionD.IdActivo,
    OperacionD.IdEstructuraContableE,
    OperacionD.IdCorte,
    OperacionD.IdImpuesto,
    OperacionD.IdEntidad3,
    OperacionD.IdAlmacen,
    OperacionD.IdDivision,
    OperacionD.IdProyecto,
    OperacionD.IdAuxiliar,
    OperacionD.IdEntidad1,
    OperacionD.IdEntidad2,
    ImporteGravado = ROUND (OperacionD.ImporteGravado * OperacionPadre.FactorDivisa, 2),
    ImporteExento = ROUND (OperacionD.ImporteExento * OperacionPadre.FactorDivisa, 2),
    ImporteDeduccionGravado = ROUND (OperacionD.ImporteDeduccionGravado * OperacionPadre.FactorDivisa, 2),
    ImporteDeduccionExento = ROUND (OperacionD.ImporteDeduccionExento * OperacionPadre.FactorDivisa, 2),
    IEPS = ROUND (OperacionD.IEPS * OperacionPadre.FactorDivisa, 2),
    ISR = ROUND (OperacionD.ISR * OperacionPadre.FactorDivisa, 2),
    BaseIVA = ROUND (OperacionD.BaseIVA * OperacionPadre.FactorDivisa, 2),
    IVA = ROUND (OperacionD.IVA * OperacionPadre.FactorDivisa, 2),
    Impuesto.TasaIVA,
    Impuesto.TasaRetencionIVA,
    Impuesto.TasaRetencionISR,
    Impuesto1 = ROUND (OperacionD.Impuesto1 * OperacionPadre.FactorDivisa, 2),
    Impuesto2 = ROUND (OperacionD.Impuesto2 * OperacionPadre.FactorDivisa, 2),
    RetencionImpuesto1 = ROUND (OperacionD.RetencionImpuesto1 * OperacionPadre.FactorDivisa, 2),
    RetencionImpuesto2 = ROUND (OperacionD.RetencionImpuesto2 * OperacionPadre.FactorDivisa, 2),
    RetencionISR = ROUND (OperacionD.RetencionISR * OperacionPadre.FactorDivisa, 2),
    RetencionIVA = ROUND (OperacionD.RetencionIVA * OperacionPadre.FactorDivisa, 2),
    Salida = ISNULL (OperacionD.Salida, 0),
    Subtotal = ROUND (OperacionD.Subtotal * OperacionPadre.FactorDivisa, 2),
    CostoTotal = ROUND (OperacionD.CostoTotal * OperacionPadre.FactorDivisa, 2),
    Pagado = ROUND (OperacionD.Pagado * OperacionPadre.FactorDivisa, 2),
    Generado = ROUND (OperacionD.Generado * OperacionPadre.FactorDivisa, 2),
    EstimacionCargo = ISNULL (ROUND (OperacionDestimacion.EstimacionCargo * OperacionPadre.FactorDivisa, 2), 0),
    EstimacionAbono = ISNULL (ROUND (OperacionDestimacion.EstimacionAbono * OperacionPadre.FactorDivisa, 2), 0),
    OperacionD.Concepto,
    OperacionD.Referencia,
    OperacionPadre.IdPeriodo,
    IdEstructuraContableEimpuesto = Impuesto.IdEstructuraContable,
    OperacionPadre.IdOperacion,
    OperacionPadre.IdTipoOperacion,
    IdTipoDDominioSubOperacion = TipoOperacion.IdTipoDdominio,
    OperacionIdCierre = OperacionPadre.IdCierre,
    OperacionIdCorte = OperacionPadre.IdCorte,
    OperacionPadre.IdListaDPoliza,
    OperacionPadre.TienePoliza,
    IdOperacionTransaccion = OperacionD.RelOperacionD,
    IdEstatusDominio = ISNULL (OperacionD.IdEstatusDominio, 1),
    Operacion.IdPersona,
    Estatus.IdEstatus
FROM dbo.tGRLoperacionesD OperacionD WITH(NOLOCK)
INNER JOIN dbo.tCTLestatus Estatus WITH(NOLOCK)ON Estatus.IdEstatus = OperacionD.IdEstatus
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH(NOLOCK)ON TipoOperacion.IdTipoOperacion = OperacionD.IdTipoSubOperacion
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH(NOLOCK)ON BienServicio.IdBienServicio = OperacionD.IdBienServicio
INNER JOIN dbo.tIMPimpuestos Impuesto WITH(NOLOCK)ON Impuesto.IdImpuesto = OperacionD.IdImpuesto
INNER JOIN dbo.tGRLoperaciones Operacion WITH(NOLOCK)ON Operacion.IdOperacion > 0 AND Operacion.IdOperacion = OperacionD.RelOperacionD
INNER JOIN dbo.tGRLoperaciones OperacionPadre WITH(NOLOCK)ON OperacionPadre.IdOperacion = Operacion.IdOperacionPadre
LEFT JOIN dbo.tGRLoperacionesDestimacion OperacionDestimacion WITH(NOLOCK)ON OperacionDestimacion.IdOperacionD = OperacionD.IdOperacionD;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  18/09/2021
=============================================*/
IF EXISTS (SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vCNTtransaccionesF'))
    DROP VIEW dbo.vCNTtransaccionesF;
GO


CREATE VIEW [dbo].[vCNTtransaccionesF]
AS
SELECT tFinanciera.IdAuxiliar,
    tFinanciera.IdEstructuraContableE,
    tFinanciera.IdCentroCostos,
    tFinanciera.IdImpuesto,
    Impuesto.TasaIVA,
    Impuesto.TasaRetencionIVA,
    Impuesto.TasaRetencionISR,
    tFinanciera.IdDivisa,
    tFinanciera.IdDivision,
    tFinanciera.IdProyecto,
    tFinanciera.IdCuenta,
    tFinanciera.IdEntidad1,
    tFinanciera.IdEntidad2,
    tFinanciera.IdEntidad3,
    tFinanciera.IdBienServicio,
    tFinanciera.Concepto,
    tFinanciera.Referencia,
    tFinanciera.IdEstatus,
    tFinanciera.IdEstatusDominio,
    operacionPadre.IdOperacion,
    tFinanciera.IdSucursal,
    tFinanciera.IdTipoDominioDestino,
    tFinanciera.IdTipoDominioOrigen,
    tFinanciera.IdTipoSubOperacion,
    tFinanciera.IdTransaccion,
    tFinanciera.Ahorrado,
    tFinanciera.CancelacionAjuste,
    tFinanciera.CancelacionAjusteAdicional,
    tFinanciera.CapitalCastigado,
    tFinanciera.CapitalCastigadoVencido,
    tFinanciera.CapitalCondonado,
    tFinanciera.CapitalCondonadoVencido,
    tFinanciera.CapitalGenerado,
    tFinanciera.CapitalGeneradoVencido,
    tFinanciera.CapitalPagado,
    tFinanciera.CapitalPagadoVencido,
    tFinanciera.CapitalVencido,
    tFinanciera.CapitalVencidoVigente,
    tFinanciera.CapitalVigenteVencido,
    tFinanciera.CargosCondonados,
    tFinanciera.CargosGenerados,
    tFinanciera.CargosPagados,
    tFinanciera.Estimacion,
    tFinanciera.EstimacionAdicional,
    tFinanciera.EstimacionAdicionalAjuste,
    tFinanciera.EstimacionAjuste,
    tFinanciera.ImpuestosPagados,
    tFinanciera.InteresCapitalizado,
    tFinanciera.InteresMoratorioACuentasOrden,
    tFinanciera.InteresMoratorioCalculado,
    tFinanciera.InteresMoratorioCastigado,
    tFinanciera.InteresMoratorioCastigadoVencido,
    tFinanciera.InteresMoratorioCondonado,
    tFinanciera.InteresMoratorioCondonadoVencido,
    tFinanciera.InteresMoratorioDeCuentasOrden,
    tFinanciera.InteresMoratorioDevengado,
    tFinanciera.InteresMoratorioDevengadoVencido,
    tFinanciera.InteresMoratorioEstimado,
    tFinanciera.InteresMoratorioPagado,
    tFinanciera.InteresMoratorioPagadoVencido,
    tFinanciera.InteresMoratorioVigenteVencido,
    tFinanciera.InteresOrdinarioACuentasOrden,
    tFinanciera.InteresOrdinarioCalculado,
    tFinanciera.InteresOrdinarioCastigado,
    tFinanciera.InteresOrdinarioCastigadoVencido,
    tFinanciera.InteresOrdinarioCondonado,
    tFinanciera.InteresOrdinarioCondonadoVencido,
    tFinanciera.InteresOrdinarioDeCuentasOrden,
    tFinanciera.InteresOrdinarioDevengado,
    tFinanciera.InteresOrdinarioDevengadoVencido,
    tFinanciera.InteresOrdinarioPagado,
    tFinanciera.InteresOrdinarioPagadoVencido,
    tFinanciera.InteresOrdinarioVencidoVigente,
    tFinanciera.InteresOrdinarioVigenteVencido,
    tFinanciera.IVACargosCondonado,
    tFinanciera.IVACargosGenerados,
    tFinanciera.IVACargosPagado,
    tFinanciera.IVAcastigado,
    tFinanciera.IVACondonado,
    tFinanciera.IVADevengado,
    tFinanciera.IVAInteresMoratorioCondonado,
    tFinanciera.IVAInteresMoratorioDevengado,
    tFinanciera.IVAInteresMoratorioPagado,
    tFinanciera.IVAInteresOrdinarioCondonado,
    tFinanciera.IVAInteresOrdinarioDevengado,
    tFinanciera.IVAInteresOrdinarioPagado,
    tFinanciera.IVAPagado,
    tFinanciera.MontoBloqueado,
    tFinanciera.MontoDesbloqueado,
    tFinanciera.MontoSubOperacion,
    tFinanciera.RetencionesGeneradas,
    tFinanciera.RetencionesPagadas,
    tFinanciera.RetencionIDE,
    tFinanciera.RetencionISR,
    tFinanciera.SaldoCapitalAnterior,
    tFinanciera.SubTotalPagado,
    tFinanciera.TotalAbonos,
    tFinanciera.TotalCargos,
    tFinanciera.TotalCondonado,
    tFinanciera.TotalGenerado,
    tFinanciera.TotalPagado,
    operacionPadre.IdPeriodo,
    cuenta.IdSocio,
    socio.IdPersona,
    IdEstructuraContableEimpuesto = Impuesto.IdEstructuraContable,
    operacionPadre.IdTipoOperacion,
    IdTipoDDominioSubOperacion = tipoOperacion.IdTipoDdominio,
    IdTipoDDominio = tipoD.IdTipoD,
    OperacionIdCierre = operacionPadre.IdCierre,
    OperacionIdCorte = operacionPadre.IdCorte,
    operacionPadre.IdListaDPoliza,
    operacionPadre.TienePoliza,
    InteresAcapitalizar = ISNULL (tFinanciera.InteresAcapitalizar, 0),
    InteresRetirado = ISNULL (tFinanciera.InteresRetirado, 0),
    tFinanciera.IdSaldoDestino,
    EstimacionRiesgosOperativosAjuste = ISNULL (EstimacionRiesgosOperativosAjuste, 0),
    EstimacionCNBVajuste = ISNULL (EstimacionCNBVajuste, 0),
    FechaOperacion = operacionPadre.Fecha,
    IdOperacionTransaccion = operacionHija.IdOperacion,
    saldo.Naturaleza
FROM dbo.tCTLtiposOperacion tipoOperacion WITH(NOLOCK)
INNER JOIN dbo.tSDOtransaccionesFinancieras tFinanciera WITH(NOLOCK)ON tipoOperacion.IdTipoOperacion = tFinanciera.IdTipoSubOperacion AND tFinanciera.IdTransaccion <> 0 AND tFinanciera.IdOperacion > 0
INNER JOIN dbo.tIMPimpuestos Impuesto WITH(NOLOCK)ON Impuesto.IdImpuesto = tFinanciera.IdImpuesto
INNER JOIN dbo.tAYCcuentas cuenta WITH(NOLOCK)ON cuenta.IdCuenta = tFinanciera.IdCuenta
INNER JOIN dbo.tSDOsaldos saldo(NOLOCK)ON saldo.IdSaldo = tFinanciera.IdSaldoDestino
INNER JOIN dbo.tCTLtiposD tipoD WITH(NOLOCK)ON saldo.IdTipoDDominioCatalogo = tipoD.IdTipoD
INNER JOIN dbo.tSCSsocios socio WITH(NOLOCK)ON socio.IdSocio = cuenta.IdSocio
INNER JOIN dbo.tGRLoperaciones operacionHija WITH(NOLOCK)ON operacionHija.IdOperacion = tFinanciera.IdOperacion
INNER JOIN dbo.tGRLoperaciones operacionPadre WITH(NOLOCK)ON operacionPadre.IdOperacion = operacionHija.IdOperacionPadre
WHERE operacionHija.IdOperacion > 0 AND ISNULL (tFinanciera.NumeroCargo, 0) = 0;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  20/09/2021
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCNTgenerarPolizaBaseDatos'))
DROP PROCEDURE pCNTgenerarPolizaBaseDatos
GO

CREATE PROC dbo.pCNTgenerarPolizaBaseDatos
    --TipoFiltro
    --1:Por Operación
    --2:Por cierre
    @TipoFiltro INT,
    --Cuando el tipo es:
    --1:IdOperacion
    --2:IdCierre
    @IdOperacion INT,
    @IdCierre INT,
    @IdSucursal INT,
    @IdUsuario INT,
    @IdSesion INT,
    @MostrarPoliza BIT = 0,
    @IdEstatusPoliza INTEGER = 0 OUTPUT,
    @NoAcumular BIT = 0,
    @DesahabilitarPartidasMultisucursales INT = 0,
    @Recontabilizacion BIT = 0,
    @Mensaje AS VARCHAR(MAX) = '' OUTPUT,
    @MostrarInformacionUsuario AS BIT = 1
AS
--	VERSIÓN 2.1.3
BEGIN

    --If Exists (Select 1 From dbo.vSesionesConsultasERPRISE Where IdSesionServer= @@Spid And HOST = 'AUXSISTEMAS3')
    --	Return;

    --Deshabilitamos la devolucion de los valores
    SET NOCOUNT ON;

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @Id INT = (CASE WHEN @TipoFiltro = 1 THEN
                                 @IdOperacion
                            ELSE @IdCierre
                       END);
    DECLARE @UsaMovimientoIntersucursal AS BIT = ISNULL ((SELECT IIF(Valor = 'true', 1, 0)FROM dbo.tCTLconfiguracion WITH(NOLOCK)WHERE IdConfiguracion = 17), 0);

    IF OBJECT_ID ('tempdb..#tmpAsientosOperaciones') IS NULL
        CREATE TABLE #tmpAsientosOperaciones
        (
            IdOperacion INT,
            IdEjercicio INT,
            IdPeriodo INT,
            IdListaDpoliza INT,
            IdSucursal INT,
            IdSucursalPrincipal INT,
            Cargos NUMERIC(23, 8),
            Abonos NUMERIC(23, 8),
            EsValida BIT DEFAULT 0
        );

    IF OBJECT_ID ('tempdb..#tmpAsientosContableE') IS NULL
        CREATE TABLE #tmpAsientosContableE
        (
            Fecha DATE,
            Concepto VARCHAR(300),
            IdListaDpoliza INT,
            IdEjercicio INT,
            IdPeriodo INT,
            IdSucursal INT,
            IdTipoDorigen INT DEFAULT 801,
            Idestatus INT DEFAULT 34
        );

    IF OBJECT_ID ('tempdb..#tmpAsientosContableD') IS NULL
        CREATE TABLE #tmpAsientosContableD
        (
            Id INT IDENTITY(1, 1),
            Tipo INT,
            IdOperacion INT,
            IdCierre INT,
            IdCorte INT,
            IdPeriodo INT,
            IdListaDpoliza INT,
            IdTransaccion INT,
            IdTipoOperacion INT,
            IdTipoSubOperacion INT,
            IdTipoDDominioSubOperacion INT,
            Naturaleza SMALLINT,
            IdTipoDDominio INT,
            IdEstatusDominio INT,
            --para fines de redondeo le cambiamos a numeric 2
            valor NUMERIC(23, 2),
            IdSucursal INT,
            idAsientoD INT,
            IdTipoOperacionA INT,
            IdTipoSubOperacionA INT,
            IdTipoDDominioSubOperacionA INT,
            NaturalezaA SMALLINT,
            IdEstatusDominioA INT,
            EsValida BIT DEFAULT 0,
            IdTipoDRubro INT,
            EsImpuestos BIT,
            IdEstructuraContableE INT,
            IdCentroCostos INT DEFAULT 0,
            IdImpuesto INT,
            IdDivisa INT,
            IdDivision INT,
            IdTipoDImpuesto INT,
            IdAuxiliar INT,
            IdBienServicio INT,
            IdEstructuraContableD INT DEFAULT 0,
            IdCuentaContable INT DEFAULT 0,
            IdCuentaContableComplementaria INT,
            EsCargo BIT,
            Inverso BIT,
            Partida INT,
            Cargo NUMERIC(23, 8),
            Abono NUMERIC(23, 8),
            IdSucursalPrincipal INT,
            BaseIVA NUMERIC(18, 2),
            IVA NUMERIC(18, 2),
            TasaIVA NUMERIC(18, 2),
            TasaRetencionIVA NUMERIC(18, 2),
            TasaRetencionISR NUMERIC(18, 2),
            EsIntersucursal BIT
        );

    IF OBJECT_ID ('tempdb..#tmpAsientosContableDatosAdicional') IS NULL
        CREATE TABLE #tmpAsientosContableDatosAdicional
        (
            Tipo INT DEFAULT 0,
            IdTransaccionPoliza INT DEFAULT 0,
            IdProyecto INT DEFAULT 0,
            IdCuenta INT DEFAULT 0,
            IdAuxiliar INT DEFAULT 0,
            IdEntidad1 INT DEFAULT 0,
            IdEntidad2 INT DEFAULT 0,
            IdEntidad3 INT DEFAULT 0,
            IdPersona INT DEFAULT 0,
            IdSocio INT DEFAULT 0,
            IdCliente INT DEFAULT 0,
            IdClienteFiscal INT DEFAULT 0,
            IdEmisorProveedor INT DEFAULT 0,
            IdProveedorFiscal INT DEFAULT 0,
            IdBienServicio INT DEFAULT 0,
            IdAlmacen INT DEFAULT 0,
            IdDivision INT DEFAULT 0,
            IdCuentaABCD INT DEFAULT 0,
            IdDivisa INT DEFAULT 0,
            IdOperacion INT DEFAULT 0,
            IdOperacionDOrigen INT DEFAULT 0,
            IdTransaccion INT DEFAULT 0,
            IdTransaccionFinanciera INT DEFAULT 0,
            IdSucursal INT DEFAULT 0,
            Concepto VARCHAR(80) DEFAULT '',
            Referencia VARCHAR(30) DEFAULT '',
            IdSaldoDestino INT DEFAULT 0,
            IdOperacionTransaccion INT DEFAULT 0,
            IdTransaccionImpuesto INT DEFAULT 0,
            IdOperacionCuentasOrden INT DEFAULT 0
        );

    INSERT INTO #tmpAsientosContableDatosAdicional
    DEFAULT VALUES;

    INSERT INTO #tmpAsientosContableE(IdEjercicio, IdPeriodo, IdSucursal, Fecha, IdListaDpoliza, Concepto)
    EXEC dbo.pCNTgenerarE @IdCierre = @IdCierre,
        @IdOperacion = @IdOperacion,
        @TipoFiltro = @TipoFiltro;

    -------------------------------------------------------------------------------------
    --						1 CREDITO
    -------------------------------------------------------------------------------------	
    DECLARE @sql VARCHAR(MAX) = '';

    BEGIN
        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 1,
            @TipoFiltro = @TipoFiltro,
            @Credito = 0,
            @IdOperacion = @Id,
            @sql = @sql OUTPUT,
            @MostrarPoliza = @MostrarPoliza;

        INSERT INTO #tmpAsientosContableD(Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, Naturaleza, IdTipoDDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdTipoDDominioSubOperacionA, NaturalezaA)
        EXEC(@sql);

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 1 AND ((c.IdTipoSubOperacionA = 0) OR (c.IdTipoSubOperacionA <> 0 AND c.IdTipoSubOperacionA = c.IdTipoSubOperacion)) AND ((c.IdTipoDDominioSubOperacionA = 0) OR (c.IdTipoDDominioSubOperacionA <> 0 AND c.IdTipoDDominioSubOperacionA = c.IdTipoDDominioSubOperacion)) AND ((NOT c.IdTipoDDominio IN (136, 137, 700)) OR (c.IdTipoDDominio IN (136, 137, 700) AND c.NaturalezaA = c.Naturaleza));

        -- clientes, proveedores, deudores

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = f.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            EsCargo = (CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN
                                 0
                            WHEN c.valor < 0 AND d.EsCargo = 0 THEN
                                 1
                            ELSE d.EsCargo
                       END),
            IdEstructuraContableE = IIF(d.EsImpuestos = 1, f.IdEstructuraContableEimpuesto, f.IdEstructuraContableE),
            IdCentroCostos = f.IdCentroCostos,
            IdTipoDRubro = d.IdTipoDRubro,
            EsImpuestos = d.EsImpuestos,
            IdImpuesto = f.IdImpuesto,
            IdTipoDImpuesto = IIF(d.EsImpuestos = 1, d.IdTipoDImpuesto, NULL),
            IdDivisa = f.IdDivisa,
            IdAuxiliar = f.IdAuxiliar,
            IdOperacion = f.IdOperacion,
            IdSucursal = f.IdSucursal
        FROM #tmpAsientosContableD c
        INNER JOIN dbo.vCNTasientosDpolizas d ON d.IdAsientoD = c.idAsientoD
        INNER JOIN dbo.vCNTtransacciones f ON f.IdTransaccion = c.IdTransaccion
        WHERE c.Tipo = 1 AND c.EsValida = 1;
    END;

    -------------------------------------------------------------------------------------
    --						2 AHORRO / INVERSION
    -------------------------------------------------------------------------------------
    BEGIN
        SET @sql = '';

        --asientosD para ahorro e inversión
        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 2,
            @TipoFiltro = @TipoFiltro,
            @Credito = 0,
            @IdOperacion = @Id,
            @sql = @sql OUTPUT,
            @MostrarPoliza = @MostrarPoliza;

        INSERT INTO #tmpAsientosContableD(Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoOperacionA, IdTipoDDominioSubOperacionA, IdEstatusDominioA)
        EXEC(@sql);

        SET @sql = '';

        --asientosD para crédito
        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 2,
            @TipoFiltro = @TipoFiltro,
            @Credito = 1,
            @IdOperacion = @Id,
            @sql = @sql OUTPUT,
            @MostrarPoliza = @MostrarPoliza;

        INSERT INTO #tmpAsientosContableD(Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoOperacionA, IdTipoDDominioSubOperacionA, IdEstatusDominioA)
        EXEC(@sql);

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 2 AND (((c.IdTipoOperacionA = 0) OR (IdTipoOperacionA <> 0 AND c.IdTipoOperacionA = c.IdTipoOperacion)) OR (c.IdTipoOperacion = 41 AND c.IdTipoSubOperacion = c.IdTipoOperacionA AND c.IdTipoOperacionA IN (6, 14))) AND ((c.IdTipoDDominioSubOperacionA = 0) OR (c.IdTipoDDominioSubOperacionA <> 0 AND c.IdTipoDDominioSubOperacionA = c.IdTipoDDominioSubOperacion)) AND ((c.IdEstatusDominioA = 0) OR (c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = TransaccionF.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            IdEstructuraContableE = IIF(d.EsImpuestos = 1, TransaccionF.IdEstructuraContableEimpuesto, TransaccionF.IdEstructuraContableE),
            IdCentroCostos = TransaccionF.IdCentroCostos,
            IdTipoDRubro = d.IdTipoDRubro,
            EsImpuestos = d.EsImpuestos,
            IdImpuesto = TransaccionF.IdImpuesto,
            IdTipoDImpuesto = IIF(d.EsImpuestos = 1, d.IdTipoDImpuesto, NULL),
            IdDivisa = TransaccionF.IdDivisa,
            IdDivision = TransaccionF.IdDivision,
            IdAuxiliar = TransaccionF.IdAuxiliar,
            IdSucursal = TransaccionF.IdSucursal,
            BaseIVA = CASE TransaccionF.TasaIVA WHEN 0 THEN
                                                     0
                                                ELSE CASE d.Campo WHEN 'InteresOrdinarioPagado' THEN
                                                                       TransaccionF.InteresOrdinarioPagado
                                                                  WHEN 'InteresOrdinarioPagadoVencido' THEN
                                                                       TransaccionF.InteresOrdinarioPagadoVencido
                                                                  WHEN 'InteresMoratorioPagado' THEN
                                                                       TransaccionF.InteresMoratorioPagado
                                                                  WHEN 'InteresMoratorioPagadoVencido' THEN
                                                                       TransaccionF.InteresMoratorioPagadoVencido
                                                                  ELSE 0
                                                     END
                      END,
            IVA = CASE d.Campo WHEN 'InteresOrdinarioPagado' THEN
                                    ROUND (TransaccionF.InteresOrdinarioPagado * TransaccionF.TasaIVA, 2)
                               WHEN 'InteresOrdinarioPagadoVencido' THEN
                                    ROUND (TransaccionF.InteresOrdinarioPagadoVencido * TransaccionF.TasaIVA, 2)
                               WHEN 'InteresMoratorioPagado' THEN
                                    ROUND (TransaccionF.InteresMoratorioPagado * TransaccionF.TasaIVA, 2)
                               WHEN 'InteresMoratorioPagadoVencido' THEN
                                    ROUND (TransaccionF.InteresMoratorioPagadoVencido * TransaccionF.TasaIVA, 2)
                               ELSE 0
                  END,
            TasaIVA = TransaccionF.TasaIVA,
            TasaRetencionIVA = TransaccionF.TasaRetencionIVA,
            TasaRetencionISR = TransaccionF.TasaRetencionISR,
            EsCargo = (CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN
                                 0
                            WHEN c.valor < 0 AND d.EsCargo = 0 THEN
                                 1
                            ELSE d.EsCargo
                       END)
        FROM #tmpAsientosContableD c
        INNER JOIN dbo.vCNTasientosDpolizas d ON d.IdAsientoD = c.idAsientoD
        INNER JOIN dbo.vCNTtransaccionesF TransaccionF ON TransaccionF.IdTransaccion = c.IdTransaccion
        WHERE c.Tipo = 2 AND c.EsValida = 1;
    END;

    -------------------------------------------------------------------------------------
    --								3 OPERACIONESD
    -------------------------------------------------------------------------------------
    BEGIN
        SET @sql = '';

        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 3,
            @TipoFiltro = @TipoFiltro,
            @Credito = 0,
            @IdOperacion = @Id,
            @sql = @sql OUTPUT,
            @MostrarPoliza = @MostrarPoliza;

        INSERT INTO #tmpAsientosContableD(Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA)
        EXEC(@sql);

        PRINT @sql;

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 3 AND ((c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoSubOperacion)) AND ((c.IdEstatusDominioA = 0) OR (c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = OperacionD.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            IdEstructuraContableE = IIF(AsientoPoliza.EsImpuestos = 1, OperacionD.IdEstructuraContableEimpuesto, OperacionD.IdEstructuraContableE),
            IdCentroCostos = OperacionD.IdCentroCostos,
            IdTipoDRubro = AsientoPoliza.IdTipoDRubro,
            EsImpuestos = AsientoPoliza.EsImpuestos,
            IdImpuesto = OperacionD.IdImpuesto,
            IdTipoDImpuesto = IIF(AsientoPoliza.EsImpuestos = 1, AsientoPoliza.IdTipoDImpuesto, NULL),
            IdDivision = OperacionD.IdDivision,
            IdAuxiliar = OperacionD.IdAuxiliar,
            IdSucursal = OperacionD.IdSucursal,
            IdBienServicio = OperacionD.IdBienServicio,
            BaseIVA = OperacionD.BaseIVA,
            IVA = OperacionD.IVA,
            TasaIVA = OperacionD.TasaIVA,
            TasaRetencionIVA = OperacionD.TasaRetencionIVA,
            TasaRetencionISR = OperacionD.TasaRetencionISR,
            EsCargo = (CASE WHEN c.valor < 0 AND AsientoPoliza.EsCargo = 1 THEN
                                 0
                            WHEN c.valor < 0 AND AsientoPoliza.EsCargo = 0 THEN
                                 1
                            ELSE AsientoPoliza.EsCargo
                       END)
        FROM #tmpAsientosContableD c
        INNER JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdAsientoD = c.idAsientoD
        INNER JOIN dbo.vCNToperacionesD OperacionD ON OperacionD.IdOperacionD = c.IdTransaccion
        WHERE c.Tipo = 3 AND c.EsValida = 1;
    END;

    -------------------------------------------------------------------------------------
    --									4 IMPUESTOS
    -------------------------------------------------------------------------------------
    BEGIN
        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 4,
            @TipoFiltro = @TipoFiltro,
            @Credito = 0,
            @IdOperacion = @Id,
            @sql = '',
            @MostrarPoliza = @MostrarPoliza;

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 4 AND ((c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoSubOperacion)) AND ((c.IdEstatusDominioA = 0) OR (c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = TransaccionImpuesto.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            IdEstructuraContableE = TransaccionImpuesto.IdEstructuraContableEimpuesto,
            IdCentroCostos = TransaccionImpuesto.IdCentroCostos,
            IdTipoDRubro = d.IdTipoDRubro,
            EsImpuestos = d.EsImpuestos,
            IdImpuesto = TransaccionImpuesto.IdImpuesto,
            IdTipoDImpuesto = d.IdTipoDImpuesto,
            IdSucursal = TransaccionImpuesto.IdSucursal,
            EsCargo = (CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN
                                 0
                            WHEN c.valor < 0 AND d.EsCargo = 0 THEN
                                 1
                            ELSE d.EsCargo
                       END),
            BaseIVA = TransaccionImpuesto.BaseIVA,
            IVA = TransaccionImpuesto.IVA,
            TasaIVA = TransaccionImpuesto.TasaIVA,
            TasaRetencionIVA = TransaccionImpuesto.TasaRetencionIVA,
            TasaRetencionISR = TransaccionImpuesto.TasaRetencionISR
        FROM #tmpAsientosContableD c
        INNER JOIN dbo.vCNTasientosDpolizas d ON d.IdAsientoD = c.idAsientoD
        INNER JOIN dbo.vCNTtransaccionesImpuestos TransaccionImpuesto ON TransaccionImpuesto.IdTransaccionImpuesto = c.IdTransaccion
        WHERE c.Tipo = 4 AND c.EsValida = 1;
    END;

    -------------------------------------------------------------------------------------
    --								5 GENERALES
    -------------------------------------------------------------------------------------
    BEGIN
        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 5,
            @TipoFiltro = @TipoFiltro,
            @Credito = 0,
            @IdOperacion = @Id,
            @sql = '',
            @MostrarPoliza = @MostrarPoliza;

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 5 AND ((c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoSubOperacion)) AND ((c.IdEstatusDominioA = 0) OR (c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = f.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            IdEstructuraContableE = f.IdEstructuraContableE,
            IdCentroCostos = f.IdCentroCostos,
            IdTipoDRubro = d.IdTipoDRubro,
            EsImpuestos = 0,
            IdImpuesto = 0,
            IdTipoDImpuesto = 0,
            IdSucursal = f.IdSucursal,
            EsCargo = (CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN
                                 0
                            WHEN c.valor < 0 AND d.EsCargo = 0 THEN
                                 1
                            ELSE d.EsCargo
                       END)
        FROM #tmpAsientosContableD c
        JOIN dbo.vCNTasientosDpolizas d ON d.IdAsientoD = c.idAsientoD
        JOIN dbo.vCNToperaciones f ON f.IdOperacionTransaccion = c.IdTransaccion
        WHERE c.Tipo = 5 AND c.EsValida = 1;
    END;

    -------------------------------------------------------------------------------------
    --								6 CUENTAS ORDEN 
    --						CONTROL DE INGRESO GASTO Y OTROS
    -------------------------------------------------------------------------------------
    BEGIN
        SET @sql = '';

        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 6,
            @TipoFiltro = @TipoFiltro,
            @Credito = 0,
            @IdOperacion = @Id,
            @sql = @sql OUTPUT,
            @MostrarPoliza = @MostrarPoliza;

        INSERT INTO #tmpAsientosContableD(Tipo, IdOperacion, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA)
        EXEC(@sql);

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 6 AND ((c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoOperacion)) AND ((c.IdEstatusDominioA = 0) OR (c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = CuentasOrden.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            IdEstructuraContableE = CuentasOrden.IdEstructuraContableE,
            IdCentroCostos = CuentasOrden.IdCentroCostos,
            IdTipoDRubro = AsientoD.IdTipoDRubro,
            EsImpuestos = 0,
            IdImpuesto = CuentasOrden.IdImpuesto,
            IdTipoDImpuesto = NULL,
            IdDivision = CuentasOrden.IdDivision,
            IdAuxiliar = CuentasOrden.IdAuxiliar,
            IdSucursal = CuentasOrden.IdSucursal,
            IdBienServicio = CuentasOrden.IdBienServicio,
            EsCargo = (CASE WHEN c.valor < 0 AND AsientoD.EsCargo = 1 THEN
                                 0
                            WHEN c.valor < 0 AND AsientoD.EsCargo = 0 THEN
                                 1
                            ELSE AsientoD.EsCargo
                       END),
            c.BaseIVA = CuentasOrden.BaseIVA,
            c.IVA = CuentasOrden.IVA,
            c.TasaIVA = CuentasOrden.TasaIVA,
            c.TasaRetencionIVA = CuentasOrden.TasaRetencionIVA,
            c.TasaRetencionISR = CuentasOrden.TasaRetencionISR
        FROM #tmpAsientosContableD c
        INNER JOIN dbo.vCNTasientosDpolizas AsientoD ON AsientoD.IdAsientoD = c.idAsientoD
        INNER JOIN dbo.vCNToperacionesCuentasOrden CuentasOrden ON CuentasOrden.IdOperacionCuentasOrden = c.IdTransaccion
        WHERE c.Tipo = 6 AND c.EsValida = 1;
    END;

    -------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------
    IF EXISTS (SELECT TOP(1)Tipo FROM #tmpAsientosContableD)
    BEGIN
        --se busca la estructura contable
        UPDATE c
        SET IdEstructuraContableD = e.IdEstructuraContableD,
            IdCuentaContable = e.IdCuentaContable,
            IdCuentaContableComplementaria = e.IdCuentaContableComplementaria,
            IdCentroCostos = IIF(e.EsBalance = 1, e.IdCentroCostos, c.IdCentroCostos),
            Cargo = IIF(c.EsCargo = 1, ABS (c.valor), 0),
            Abono = IIF(c.EsCargo = 0, ABS (c.valor), 0)
        FROM #tmpAsientosContableD c
        LEFT JOIN dbo.vCNTestructurasContablesDpolizas e ON e.IdEstructuraContableE = c.IdEstructuraContableE
        WHERE e.IdTipoDRubro = c.IdTipoDRubro AND ((e.TipoDivisaDivision = 0 AND e.IdTipoDimpuesto = c.IdTipoDImpuesto) OR (e.TipoDivisaDivision = 2 AND e.IdDivisa = c.IdDivisa) OR (e.TipoDivisaDivision = 1 AND e.IdDivision = c.IdDivision) OR (e.TipoDivisaDivision = 3 AND e.IdDivisa = c.IdDivisa AND e.IdAuxiliar = c.IdAuxiliar) OR (e.TipoDivisaDivision = 4 AND e.IdDivision = c.IdDivision AND e.IdBienServicio = c.IdBienServicio));
    END;

    INSERT INTO #tmpAsientosOperaciones(IdOperacion, IdEjercicio, IdPeriodo, IdListaDpoliza, IdSucursalPrincipal, Cargos, Abonos)
    SELECT e.IdOperacion,
        Periodo.IdEjercicio,
        e.IdPeriodo,
        e.IdListaDpoliza,
        (SELECT TOP(1)IdSucursal
         FROM #tmpAsientosContableD b
         WHERE b.EsValida = 1 AND Tipo <> 3 AND b.IdOperacion = e.IdOperacion
         ORDER BY b.Tipo,
             b.IdTransaccion) AS IdSucursalPrincipal,
        Cargos = SUM (e.Cargo),
        Abonos = SUM (e.Abono)
    FROM #tmpAsientosContableD e
    INNER JOIN dbo.tCTLperiodos Periodo ON Periodo.IdPeriodo = e.IdPeriodo
    GROUP BY e.IdOperacion,
        Periodo.IdEjercicio,
        e.IdPeriodo,
        e.IdListaDpoliza;

    IF(@DesahabilitarPartidasMultisucursales <> 999)
    BEGIN
        IF(@UsaMovimientoIntersucursal = 1)
        BEGIN
            IF @IdOperacion IN (939562) --177112
            BEGIN
                UPDATE #tmpAsientosOperaciones
                SET IdSucursalPrincipal = 53;
            END;

            UPDATE t
            SET IdSucursalPrincipal = tmp.IdSucursalPrincipal
            FROM #tmpAsientosContableD t
            INNER JOIN #tmpAsientosOperaciones AS tmp ON tmp.IdOperacion = t.IdOperacion;

            /*
				GENERAMOS LOS MOVIMIENTOS INTERSUCURSAL
			*/
            INSERT INTO #tmpAsientosContableD(Tipo, IdTransaccion, IdOperacion, IdPeriodo, IdListaDpoliza, IdSucursal, IdSucursalPrincipal, EsCargo, Cargo, Abono, EsIntersucursal, EsValida, IdImpuesto, idAsientoD)
            SELECT Tipo = 0,
                IdTransaccion = 0,
                IdOperacion,
                IdPeriodo,
                IdListaDpoliza,
                IdSucursal,
                IdSucursalPrincipal,
                EsCargo,
                IIF(EsCargo = 1, ABS (cambioNeto), 0) AS Cargo,
                IIF(EsCargo = 0, ABS (cambioNeto), 0) AS Abono,
                EsIntersucursal = 1,
                EsValida = 1,
                IdImpuesto = 0,
                IdAsientoD = 0
            FROM(SELECT IdOperacion,
                     IdPeriodo,
                     IdListaDpoliza,
                     IdSucursal,
                     IdSucursalPrincipal,
                     IIF(SUM (Cargo) > SUM (Abono), 0, 1) EsCargo,
                     SUM (Cargo) - SUM (Abono) AS cambioNeto
                 FROM #tmpAsientosContableD
                 WHERE IdSucursal <> IdSucursalPrincipal
                 GROUP BY IdOperacion,
                     IdPeriodo,
                     IdListaDpoliza,
                     IdSucursal,
                     IdSucursalPrincipal) AS x
            WHERE ABS (cambioNeto) > 0;

            INSERT INTO #tmpAsientosContableD(Tipo, IdTransaccion, IdOperacion, IdPeriodo, IdListaDpoliza, IdSucursal, IdSucursalPrincipal, EsCargo, Cargo, Abono, EsIntersucursal, EsValida, IdImpuesto, idAsientoD)
            SELECT 0,
                0,
                IdOperacion,
                IdPeriodo,
                IdListaDpoliza,
                IdSucursalPrincipal,
                IdSucursalPrincipal,
                EsCargo = IIF(EsCargo = 1, 0, 1),
                Abono,
                Cargo,
                EsIntersucursal = 1,
                EsValida = 1,
                IdImpuesto = 0,
                IdAsientoD = 0
            FROM #tmpAsientosContableD
            WHERE EsValida = 1 AND EsIntersucursal = 1;

            --SELECT valor FROM tCTLconfiguracion tc	WHERE tc.IdConfiguracion = 17
            DECLARE @IdcuentaContable INT = ISNULL ((SELECT tc.IdCuentaContable
                                                     FROM dbo.tCNTcuentas tc
                                                     WHERE tc.Codigo <> '' AND Codigo = (SELECT tc.ValorCodigo FROM dbo.tCTLconfiguracion tc WHERE tc.IdConfiguracion = 18)), 0);

            IF(@IdcuentaContable <> 0)
            BEGIN
                --establecemos default el centro de balance
                UPDATE p
                SET IdCuentaContable = @IdcuentaContable,
                    IdCentroCostos = -1
                FROM #tmpAsientosContableD p
                WHERE EsValida = 1 AND EsIntersucursal = 1;
            END;
        END;
    END;

    -- ordenamiento
    UPDATE t
    SET Partida = tmp.partida
    FROM #tmpAsientosContableD t
    INNER JOIN(SELECT e.Id,
                   ROW_NUMBER () OVER (PARTITION BY e.IdPeriodo, e.IdListaDpoliza ORDER BY c.Codigo) AS partida
               FROM #tmpAsientosContableD e
               INNER JOIN dbo.tCNTcuentas c ON c.IdCuentaContable = e.IdCuentaContable
               WHERE e.EsValida = 1) AS tmp ON tmp.Id = t.Id;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional(Tipo, IdTransaccionPoliza, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdCliente, IdClienteFiscal, IdEmisorProveedor, IdProveedorFiscal, IdBienServicio, IdCuentaABCD, IdDivisa, IdOperacion, IdTransaccion, IdSucursal, Concepto, Referencia, IdSaldoDestino, IdOperacionTransaccion)
        SELECT DISTINCT tmp.Tipo,
            IdTransaccionPoliza = Transaccion.IdTransaccion,
            Transaccion.IdProyecto,
            Transaccion.IdCuenta,
            Transaccion.IdAuxiliar,
            Transaccion.IdEntidad1,
            Transaccion.IdEntidad2,
            Transaccion.IdEntidad3,
            Transaccion.IdPersona,
            Transaccion.IdCliente,
            IdClienteFiscal = Transaccion.IdCliente,
            Transaccion.IdEmisorProveedor,
            IdProveedorFiscal = Transaccion.IdEmisorProveedor,
            Transaccion.IdBienServicio,
            Transaccion.IdCuentaABCD,
            Transaccion.IdDivisa,
            Transaccion.IdOperacion,
            Transaccion.IdTransaccion,
            Transaccion.IdSucursal,
            Transaccion.Concepto,
            Transaccion.Referencia,
            Transaccion.IdSaldoDestino,
            Transaccion.IdOperacionTransaccion
        FROM dbo.vCNTtransacciones Transaccion
        INNER JOIN #tmpAsientosContableD tmp ON tmp.IdTransaccion = Transaccion.IdTransaccion
        WHERE tmp.Tipo = 1 AND tmp.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional(Tipo, IdTransaccionPoliza, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdSocio, IdBienServicio, IdDivision, IdDivisa, IdOperacion, IdTransaccionFinanciera, IdSucursal, Concepto, Referencia, IdSaldoDestino, IdOperacionTransaccion)
        SELECT DISTINCT tmp.Tipo,
            IdTransaccionPoliza = TransaccionFinanciera.IdTransaccion,
            TransaccionFinanciera.IdProyecto,
            TransaccionFinanciera.IdCuenta,
            TransaccionFinanciera.IdAuxiliar,
            TransaccionFinanciera.IdEntidad1,
            TransaccionFinanciera.IdEntidad2,
            TransaccionFinanciera.IdEntidad3,
            TransaccionFinanciera.IdPersona,
            TransaccionFinanciera.IdSocio,
            TransaccionFinanciera.IdBienServicio,
            TransaccionFinanciera.IdDivision,
            TransaccionFinanciera.IdDivisa,
            TransaccionFinanciera.IdOperacion,
            TransaccionFinanciera.IdTransaccion,
            TransaccionFinanciera.IdSucursal,
            TransaccionFinanciera.Concepto,
            TransaccionFinanciera.Referencia,
            TransaccionFinanciera.IdSaldoDestino,
            TransaccionFinanciera.IdOperacionTransaccion
        FROM dbo.vCNTtransaccionesF TransaccionFinanciera
        INNER JOIN #tmpAsientosContableD tmp ON tmp.IdTransaccion = TransaccionFinanciera.IdTransaccion
        WHERE tmp.Tipo = 2 AND tmp.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional(Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdOperacionDOrigen, IdSucursal, Concepto, Referencia, IdOperacionTransaccion, IdPersona)
        SELECT DISTINCT tmp.Tipo,
            IdTransaccionPoliza = OperacionD.IdOperacionD,
            OperacionD.IdProyecto,
            OperacionD.IdAuxiliar,
            OperacionD.IdEntidad1,
            OperacionD.IdEntidad2,
            OperacionD.IdEntidad3,
            OperacionD.IdBienServicio,
            OperacionD.IdAlmacen,
            OperacionD.IdDivision,
            OperacionD.IdOperacion,
            IdOperacionDOrigen = OperacionD.IdOperacionD,
            OperacionD.IdSucursal,
            OperacionD.Concepto,
            OperacionD.Referencia,
            OperacionD.IdOperacionTransaccion,
            OperacionD.IdPersona
        FROM dbo.vCNToperacionesD OperacionD
        INNER JOIN #tmpAsientosContableD tmp ON tmp.IdTransaccion = OperacionD.IdOperacionD
        WHERE tmp.Tipo = 3 AND tmp.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional(Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdTransaccion, IdSucursal, Concepto, Referencia, IdOperacionTransaccion, IdPersona, IdTransaccionImpuesto)
        SELECT DISTINCT tmp.Tipo,
            IdTransaccionPoliza = TransaccionImpuesto.IdTransaccionImpuesto,
            IdProyecto = 0,
            IdAuxiliar = 0,
            IdEntidad1 = 0,
            IdEntidad2 = 0,
            IdEntidad3 = 0,
            IdBienServicio = 0,
            IdAlmacen = 0,
            IdDivision = 0,
            TransaccionImpuesto.IdOperacion,
            IdTransaccion = 0,
            TransaccionImpuesto.IdSucursal,
            Concepto = 'IMPTOS',
            Referencia = 'IMP-TRAN',
            TransaccionImpuesto.IdOperacionTransaccion,
            TransaccionImpuesto.IdPersona,
            TransaccionImpuesto.IdTransaccionImpuesto
        FROM dbo.vCNTtransaccionesImpuestos TransaccionImpuesto
        INNER JOIN #tmpAsientosContableD tmp ON tmp.IdTransaccion = TransaccionImpuesto.IdTransaccionImpuesto
        WHERE tmp.Tipo = 4 AND tmp.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional(Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdSucursal, Concepto, Referencia, IdPersona, IdOperacionTransaccion, IdOperacionCuentasOrden)
        SELECT DISTINCT tmp.Tipo,
            IdTransaccionPoliza = CuentaOrden.IdOperacionCuentasOrden,
            CuentaOrden.IdProyecto,
            CuentaOrden.IdAuxiliar,
            CuentaOrden.IdEntidad1,
            CuentaOrden.IdEntidad2,
            CuentaOrden.IdEntidad3,
            CuentaOrden.IdBienServicio,
            CuentaOrden.IdAlmacen,
            CuentaOrden.IdDivision,
            CuentaOrden.IdOperacion,
            CuentaOrden.IdSucursal,
            CuentaOrden.Concepto,
            CuentaOrden.Referencia,
            CuentaOrden.IdPersona,
            CuentaOrden.IdOperacion,
            CuentaOrden.IdOperacionCuentasOrden
        FROM dbo.vCNToperacionesCuentasOrden CuentaOrden
        INNER JOIN #tmpAsientosContableD tmp ON tmp.IdTransaccion = CuentaOrden.IdOperacionCuentasOrden
        WHERE tmp.Tipo = 6 AND tmp.EsValida = 1;
    END;

    --Sí se muestra la póliza en la modalidad de desarrollo, donde se muestran los ID's no se guardará la póliza
    IF(@MostrarPoliza = 1 AND @MostrarInformacionUsuario = 0)
    BEGIN
        SELECT tmp.EsIntersucursal,
            0 IdPolizaE,
            tmp.Partida,
            tmp.IdCuentaContable,
            tmp.IdCentroCostos,
            tmp.Cargo,
            tmp.Abono,
            tmp.cuenta,
            tmp.nombreCuenta,
            tmp.Campo,
            tmp.rubro,
            AsientoContableAdicional.IdProyecto,
            AsientoContableAdicional.IdCuenta,
            AsientoContableAdicional.IdAuxiliar,
            AsientoContableAdicional.IdEntidad1,
            AsientoContableAdicional.IdEntidad2,
            AsientoContableAdicional.IdEntidad3,
            AsientoContableAdicional.IdPersona,
            AsientoContableAdicional.IdSocio,
            AsientoContableAdicional.IdCliente,
            AsientoContableAdicional.IdClienteFiscal,
            AsientoContableAdicional.IdEmisorProveedor,
            AsientoContableAdicional.IdProveedorFiscal,
            AsientoContableAdicional.IdBienServicio,
            AsientoContableAdicional.IdAlmacen,
            AsientoContableAdicional.IdDivision,
            AsientoContableAdicional.IdCuentaABCD,
            AsientoContableAdicional.IdDivisa,
            tmp.IdEstructuraContableD,
            AsientoContableAdicional.IdOperacion,
            AsientoContableAdicional.IdOperacionDOrigen,
            AsientoContableAdicional.IdTransaccion,
            AsientoContableAdicional.IdTransaccionFinanciera,
            IdSucursal = IIF(tmp.EsIntersucursal = 1, tmp.IdSucursal, AsientoContableAdicional.IdSucursal),
            tmp.idAsientoD,
            AsientoContableAdicional.Tipo,
            AsientoContableAdicional.IdTransaccionPoliza,
            tmp.IdListaDpoliza,
            tmp.IdPeriodo,
            tmp.EsValida
        FROM #tmpAsientosContableDatosAdicional AsientoContableAdicional
        RIGHT JOIN(SELECT tmp.Id,
                       tmp.Partida,
                       tmp.IdCuentaContable,
                       tmp.IdCentroCostos,
                       tmp.Cargo,
                       tmp.Abono,
                       tmp.IdEstructuraContableD,
                       tmp.Tipo,
                       tmp.IdTransaccion,
                       tmp.idAsientoD,
                       tmp.IdPeriodo,
                       tmp.IdListaDpoliza,
                       tmp.EsIntersucursal,
                       tmp.IdSucursal,
                       tmp.EsValida,
                       AsientoD.Campo,
                       rubro = Rubro.Descripcion,
                       cuenta = Cuenta.Codigo,
                       nombreCuenta = Cuenta.Descripcion
                   FROM #tmpAsientosContableD tmp
                   JOIN dbo.tCNTasientosD AsientoD WITH(NOLOCK)ON AsientoD.IdAsientoD = tmp.idAsientoD
                   JOIN dbo.tCNTcuentas Cuenta WITH(NOLOCK)ON Cuenta.IdCuentaContable = tmp.IdCuentaContable
                   JOIN dbo.tCTLtiposD Rubro WITH(NOLOCK)ON Rubro.IdTipoD = AsientoD.IdTipoDRubro) AS tmp ON tmp.Tipo = AsientoContableAdicional.Tipo AND tmp.IdTransaccion = AsientoContableAdicional.IdTransaccionPoliza
        ORDER BY tmp.IdPeriodo,
            tmp.IdListaDpoliza,
            tmp.Partida;

        IF @IdCierre <> 0
        BEGIN
            SELECT t.IdOperacion,
                Cargo = SUM (tmp.Cargo),
                Abono = SUM (tmp.Abono)
            FROM #tmpAsientosContableDatosAdicional t
            RIGHT JOIN(SELECT tmp.Id,
                           tmp.Partida,
                           tmp.Tipo,
                           tmp.IdTransaccion,
                           tmp.idAsientoD,
                           tmp.IdCuentaContable,
                           tmp.Cargo,
                           tmp.Abono
                       FROM #tmpAsientosContableD tmp
                       JOIN dbo.tCNTasientosD AsientoD WITH(NOLOCK)ON AsientoD.IdAsientoD = tmp.idAsientoD
                       JOIN dbo.tCNTcuentas Cuenta WITH(NOLOCK)ON Cuenta.IdCuentaContable = tmp.IdCuentaContable
                       JOIN dbo.tCTLtiposD Rubro WITH(NOLOCK)ON Rubro.IdTipoD = AsientoD.IdTipoDRubro) AS tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
            WHERE tmp.Partida <> 0
            GROUP BY t.IdOperacion
            HAVING(SUM (tmp.Cargo) - SUM (tmp.Abono)) <> 0;
        END;

        DECLARE @IdTipoOperacion INT;

        IF(@TipoFiltro = 1)
            SELECT @IdTipoOperacion = IdTipoOperacion
            FROM dbo.tGRLoperaciones WITH(NOLOCK)
            WHERE IdOperacion = @IdOperacion;

        IF(@IdTipoOperacion = 4 OR @IdTipoOperacion = 503)
        BEGIN
            SELECT 'CTA',
                tmp.IdPeriodo,
                tmp.IdListaDpoliza,
                IdOperacion = IIF(tmp.EsIntersucursal = 1, tmp.IdOperacion, t.IdOperacion),
                t.IdCuenta,
                Cargos = SUM (tmp.Cargo),
                Abonos = SUM (tmp.Abono)
            FROM #tmpAsientosContableDatosAdicional t
            RIGHT JOIN #tmpAsientosContableD tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
            WHERE tmp.EsValida = 1
            GROUP BY tmp.IdPeriodo,
                tmp.IdListaDpoliza,
                IIF(tmp.EsIntersucursal = 1, tmp.IdOperacion, t.IdOperacion),
                t.IdCuenta
            HAVING SUM (tmp.Cargo) <> SUM (tmp.Abono);

            SELECT t.*,
                tmp.*,
                AsientoD.Campo
            FROM #tmpAsientosContableDatosAdicional t
            RIGHT JOIN #tmpAsientosContableD tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
            JOIN dbo.tCNTasientosD AsientoD ON AsientoD.IdAsientoD = tmp.idAsientoD
            WHERE tmp.EsValida = 1;
        END;

        RETURN -1;
    END;

    --Sí se muestra la póliza en la modalidad de usuario, donde se muestran los ID's no se guardará la póliza
    IF(@MostrarPoliza = 1 AND @MostrarInformacionUsuario = 1)
    BEGIN
        SELECT tmp.Partida,
            Cuenta = tmp.cuenta,
            [Nombre cuenta] = tmp.nombreCuenta,
            tmp.Cargo,
            tmp.Abono,
            tmp.Campo,
            tmp.rubro,
            [Tipo de saldo] = auxiliar.Descripcion,
            [Bien Servicio] = bien.Descripcion,
            [Código E. Contable] = EstructuraContableE.Codigo,
            [Estructura contable] = EstructuraContableE.Descripcion,
            [División] = division.Descripcion,
            [Sucursal] = sucursal.Descripcion,
            t.Referencia,
            t.IdPersona,
            tmp.EsValida
        FROM #tmpAsientosContableDatosAdicional t
        LEFT JOIN dbo.tCNTauxiliares auxiliar ON auxiliar.IdAuxiliar = t.IdAuxiliar
        LEFT JOIN dbo.tCNTdivisiones division ON division.IdDivision = t.IdDivision
        LEFT JOIN dbo.tCTLsucursales sucursal ON sucursal.IdSucursal = t.IdSucursal
        LEFT JOIN dbo.tGRLbienesServicios bien WITH(NOLOCK)ON t.IdBienServicio = bien.IdBienServicio
        LEFT JOIN dbo.vSCSemisoresProveedores prov ON prov.IdEmisorProveedor = t.IdEmisorProveedor
        RIGHT JOIN(SELECT tmp.*,
                       AsientoD.Campo,
                       Rubro.Descripcion AS rubro,
                       Cuenta.Codigo AS cuenta,
                       Cuenta.Descripcion AS nombreCuenta
                   FROM #tmpAsientosContableD tmp
                   INNER JOIN dbo.tCNTasientosD AsientoD WITH(NOLOCK)ON AsientoD.IdAsientoD = tmp.idAsientoD
                   INNER JOIN dbo.tCNTcuentas Cuenta WITH(NOLOCK)ON Cuenta.IdCuentaContable = tmp.IdCuentaContable
                   INNER JOIN dbo.tCTLtiposD Rubro WITH(NOLOCK)ON Rubro.IdTipoD = AsientoD.IdTipoDRubro) AS tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
        LEFT JOIN dbo.tCNTestructurasContablesE EstructuraContableE ON EstructuraContableE.IdEstructuraContableE = tmp.IdEstructuraContableE
        WHERE tmp.Partida IS NOT NULL
        ORDER BY tmp.IdPeriodo,
            tmp.IdListaDpoliza,
            tmp.Partida;

        IF(@TipoFiltro = 1)
            SELECT @IdTipoOperacion = IdTipoOperacion
            FROM dbo.tGRLoperaciones WITH(NOLOCK)
            WHERE IdOperacion = @IdOperacion;

        IF(@IdTipoOperacion = 4 OR @IdTipoOperacion = 503)
        BEGIN
            SELECT 'CTA',
                tmp.IdPeriodo,
                tmp.IdListaDpoliza,
                IdOperacion = IIF(tmp.EsIntersucursal = 1, tmp.IdOperacion, t.IdOperacion),
                t.IdCuenta,
                Cargos = SUM (tmp.Cargo),
                Abonos = SUM (tmp.Abono)
            FROM #tmpAsientosContableDatosAdicional t
            RIGHT JOIN #tmpAsientosContableD tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
            WHERE tmp.EsValida = 1
            GROUP BY tmp.IdPeriodo,
                tmp.IdListaDpoliza,
                IIF(tmp.EsIntersucursal = 1, tmp.IdOperacion, t.IdOperacion),
                t.IdCuenta
            HAVING SUM (tmp.Cargo) <> SUM (tmp.Abono);

            SELECT t.*,
                tmp.*,
                tcd.Campo
            FROM #tmpAsientosContableDatosAdicional t
            RIGHT JOIN #tmpAsientosContableD tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
            INNER JOIN dbo.tCNTasientosD tcd ON tcd.IdAsientoD = tmp.idAsientoD
            WHERE tmp.EsValida = 1;
        END;

        RETURN -1;
    END;

    --validamos que cuadre por sucursal si es movimiento multisucursal
    IF(@DesahabilitarPartidasMultisucursales <> 999)
    BEGIN
        IF(@UsaMovimientoIntersucursal = 1)
        BEGIN
            IF EXISTS (SELECT tmp.IdPeriodo,
                           tmp.IdListaDpoliza,
                           tmp.IdSucursal,
                           Cargos = SUM (tmp.Cargo),
                           Abonos = SUM (tmp.Abono)
                       FROM #tmpAsientosContableDatosAdicional t
                       INNER JOIN #tmpAsientosContableD tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
                       WHERE tmp.EsValida = 1
                       GROUP BY tmp.IdPeriodo,
                           tmp.IdListaDpoliza,
                           tmp.IdSucursal
                       HAVING SUM (tmp.Cargo) <> SUM (tmp.Abono))
            BEGIN
                SET @IdEstatusPoliza = 34;

                SELECT tmp.IdPeriodo,
                    tmp.IdListaDpoliza,
                    tmp.IdSucursal,
                    Cargos = SUM (tmp.Cargo),
                    Abonos = SUM (tmp.Abono),
                    Idoperacion = MAX (tmp.IdOperacion),
                    IdTransaccion = MAX (tmp.IdTransaccion),
                    IdTransaccion2 = MIN (tmp.IdTransaccion)
                FROM #tmpAsientosContableDatosAdicional t
                INNER JOIN #tmpAsientosContableD tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
                WHERE tmp.EsValida = 1
                GROUP BY tmp.IdPeriodo,
                    tmp.IdListaDpoliza,
                    tmp.IdSucursal
                HAVING SUM (tmp.Cargo) <> SUM (tmp.Abono);

                PRINT 'cuadre por sucursal';

                RETURN -1;
            END;
        END;
    END;

    IF EXISTS (SELECT IdSucursal FROM #tmpAsientosContableD WHERE EsValida = 1 AND IdSucursal = 0)
    BEGIN
        SET @Mensaje = CONCAT ('Registros con sucursal cero ID(', @IdOperacion, ')');

        SELECT @Mensaje;

        SET @IdEstatusPoliza = 34;

        RETURN -1;
    END;

    IF EXISTS (SELECT IdSucursal FROM #tmpAsientosContableD WHERE EsValida = 1 AND IdCuentaContable = 0)
    BEGIN
        SET @Mensaje = CONCAT ('Registros sin cuenta contable ID(', @IdOperacion, ')');

        SELECT @Mensaje;

        SET @IdEstatusPoliza = 34;

        SELECT 0
        FROM #tmpAsientosContableD
        WHERE EsValida = 1 AND IdCuentaContable = 0;

        RETURN -1;
    END;

    PRINT 'ESTATUS';

    UPDATE e
    SET Idestatus = x.IdEstatus
    FROM #tmpAsientosContableE e
    JOIN(SELECT IdPeriodo,
             IdListaDpoliza,
             Partidas = COUNT (*),
             Cargos = SUM (tmp.Cargo),
             Abonos = SUM (tmp.Abono),
             IdEstatus = IIF(SUM (tmp.Cargo) = SUM (tmp.Abono), 1, 13)
         FROM #tmpAsientosContableD tmp
         WHERE EsValida = 1
         GROUP BY IdPeriodo,
             IdListaDpoliza) AS x ON x.IdPeriodo = e.IdPeriodo AND x.IdListaDpoliza = e.IdListaDpoliza;

    DECLARE @numeroPartidasValidas AS INT = (SELECT COUNT (*) FROM #tmpAsientosContableE WHERE Idestatus = 1);

    IF(@numeroPartidasValidas = 0)
    BEGIN
        SELECT Fecha,
            Concepto,
            IdListaDpoliza,
            IdEjercicio,
            IdPeriodo,
            IdSucursal,
            IdTipoDorigen,
            Idestatus
        FROM #tmpAsientosContableE
        ORDER BY IdPeriodo;

        SELECT IdPeriodo,
            IdListaDpoliza,
            Partidas = COUNT (*),
            Cargos = SUM (tmp.Cargo),
            Abonos = SUM (tmp.Abono),
            IdEstatus = IIF(SUM (tmp.Cargo) = SUM (tmp.Abono), 1, 13)
        FROM #tmpAsientosContableD tmp
        WHERE EsValida = 1
        GROUP BY IdPeriodo,
            IdListaDpoliza;

        SET @Mensaje = CONCAT ('SIN PARTIDAS VÁLIDAS (', @IdOperacion, ')');
        SET @IdEstatusPoliza = 34;

        RETURN -1;
    END;

    PRINT 'ESTATUS 2';

    --Bajamos triggers		
    BEGIN TRY
        DECLARE @IdPolizaE INT;
        DECLARE @fecha      DATE,
            @Concepto       VARCHAR(30),
            @IdListaDpoliza INT,
            @IdEjercicio    INT,
            @IdPeriodo      INT,
            @IdSucursalx    INT,
            @IdTipoDorigen  INT,
            @Idestatus      INT;

        DECLARE curPolizaE CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
        SELECT Fecha,
            Concepto,
            IdListaDpoliza,
            IdEjercicio,
            IdPeriodo,
            IdSucursal,
            IdTipoDorigen,
            Idestatus
        FROM #tmpAsientosContableE
        WHERE Idestatus = 1
        ORDER BY IdPeriodo;

        OPEN curPolizaE;

        FETCH NEXT FROM curPolizaE
        INTO @fecha,
            @Concepto,
            @IdListaDpoliza,
            @IdEjercicio,
            @IdPeriodo,
            @IdSucursalx,
            @IdTipoDorigen,
            @Idestatus;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC [dbo].[pCRUDpolizasE] @TipoOperacion = 'C',
                @IdPolizaE = @IdPolizaE OUTPUT,
                @Fecha = @fecha,
                @Concepto = @Concepto,
                @IdEjercicio = @IdEjercicio,
                @IdPeriodo = @IdPeriodo,
                @IdSucursal = @IdSucursalx,
                @IdTipoDOrigen = @IdTipoDorigen,
                @IdListaDPoliza = @IdListaDpoliza,
                @IdEstatus = @Idestatus,
                @IdUsuarioAlta = @IdUsuario,
                @CodigoInterfaz = '|',
                @IdSesion = @IdSesion;

            -- Si es recontabilización, vamos a buscar su folio original
            IF(@Recontabilizacion = 1)
            BEGIN
                IF(@TipoFiltro = 1 AND @IdOperacion <> 0)
                BEGIN
                    IF EXISTS (SELECT 1
                               FROM dbo.tCNTpolizasFoliosOperaciones wt
                               WHERE @TipoFiltro = 1 AND IdOperacion = @IdOperacion AND @IdOperacion <> 0 AND IdListaDPoliza = @IdListaDpoliza AND @IdPolizaE <> 0)
                    BEGIN
                        PRINT 'SE ULTIZA EL FOLIO ORIGINAL';

                        UPDATE PolizaE
                        SET Folio = tmp.Folio
                        FROM dbo.tCNTpolizasE PolizaE
                        JOIN(SELECT IdPolizaE = @IdPolizaE,
                                 Folio,
                                 Numero = ROW_NUMBER () OVER (ORDER BY Principal DESC)
                             FROM dbo.tCNTpolizasFoliosOperaciones
                             WHERE IdOperacion = @IdOperacion AND IdListaDPoliza = @IdListaDpoliza) tmp ON tmp.IdPolizaE = PolizaE.IdPolizaE AND tmp.Numero = 1;
                    END;
                END;
                ELSE
                BEGIN
                    IF(@TipoFiltro = 2 AND @IdCierre <> 0)
                    BEGIN
                        IF EXISTS (SELECT 1
                                   FROM dbo.tCNTpolizasFoliosOperaciones
                                   WHERE @TipoFiltro = 2 AND IdCierre = @IdCierre AND @IdCierre <> 0 AND IdListaDPoliza = @IdListaDpoliza AND @IdPolizaE <> 0)
                        BEGIN
                            PRINT 'SE ULTIZA EL FOLIO ORIGINAL';

                            UPDATE PolizaE
                            SET Folio = tmp.Folio
                            FROM dbo.tCNTpolizasE PolizaE
                            JOIN(SELECT IdPolizaE = @IdPolizaE,
                                     Folio,
                                     Numero = ROW_NUMBER () OVER (ORDER BY Principal DESC)
                                 FROM dbo.tCNTpolizasFoliosOperaciones
                                 WHERE IdCierre = @IdCierre AND IdListaDPoliza = @IdListaDpoliza) tmp ON tmp.IdPolizaE = PolizaE.IdPolizaE AND tmp.Numero = 1;
                        END;
                    END;
                END;
            END;

            PRINT @IdPolizaE;

            IF(NOT @IdPolizaE IS NULL)
            BEGIN
                /*Agregamos los detalles por periodo - tipo de póliza*/
                INSERT dbo.tCNTpolizasD(IdPolizaE, Partida, IdCuentaContable, IdCentroCostos, Cargo, Abono, BaseIVA, IVA, TasaIVA, TasaRetencionIVA, TasaRetencionISR, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdSocio, IdCliente, IdClienteFiscal, IdEmisorProveedor, IdProveedorFiscal, IdBienServicio, IdAlmacen, IdDivision, IdCuentaABCD, IdDivisa, IdEstructuraContableD, IdOperacion, IdOperacionDOrigen, IdTransaccion, IdTransaccionFinanciera, IdSucursal, IdAsientoD, IdSaldoDestino, Concepto, Referencia, IdImpuesto, IdTransaccionImpuesto, IdOperacionCuentasOrden)
                SELECT @IdPolizaE,
                    AsientoContable.Partida,
                    AsientoContable.IdCuentaContable,
                    AsientoContable.IdCentroCostos,
                    AsientoContable.Cargo,
                    AsientoContable.Abono,
                    AsientoContable.BaseIVA,
                    AsientoContable.IVA,
                    AsientoContable.TasaIVA,
                    AsientoContable.TasaRetencionIVA,
                    AsientoContable.TasaRetencionISR,
                    AsientoContableAdicional.IdProyecto,
                    AsientoContableAdicional.IdCuenta,
                    AsientoContableAdicional.IdAuxiliar,
                    AsientoContableAdicional.IdEntidad1,
                    AsientoContableAdicional.IdEntidad2,
                    AsientoContableAdicional.IdEntidad3,
                    AsientoContableAdicional.IdPersona,
                    AsientoContableAdicional.IdSocio,
                    AsientoContableAdicional.IdCliente,
                    AsientoContableAdicional.IdClienteFiscal,
                    AsientoContableAdicional.IdEmisorProveedor,
                    AsientoContableAdicional.IdProveedorFiscal,
                    AsientoContableAdicional.IdBienServicio,
                    AsientoContableAdicional.IdAlmacen,
                    AsientoContableAdicional.IdDivision,
                    AsientoContableAdicional.IdCuentaABCD,
                    AsientoContableAdicional.IdDivisa,
                    AsientoContable.IdEstructuraContableD,
                    --Cambiamos el uso del idoperacion por el idoperaciontransaccion, por que el primero hace referencia al idoperacionpadre
                    IdOperacion = IIF(AsientoContable.EsIntersucursal = 1, AsientoContable.IdOperacion, AsientoContableAdicional.IdOperacionTransaccion),
                    AsientoContableAdicional.IdOperacionDOrigen,
                    AsientoContableAdicional.IdTransaccion,
                    AsientoContableAdicional.IdTransaccionFinanciera,
                    IdSucursal = IIF(AsientoContable.EsIntersucursal = 1, AsientoContable.IdSucursal, AsientoContableAdicional.IdSucursal),
                    AsientoContable.idAsientoD,
                    AsientoContableAdicional.IdSaldoDestino,
                    Concepto = SUBSTRING (AsientoContableAdicional.Concepto, 1, 80),
                    Referencia = SUBSTRING (AsientoContableAdicional.Referencia, 1, 30),
                    AsientoContable.IdImpuesto,
                    AsientoContableAdicional.IdTransaccionImpuesto,
                    AsientoContableAdicional.IdOperacionCuentasOrden
                FROM #tmpAsientosContableDatosAdicional AsientoContableAdicional
                INNER JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.Tipo = AsientoContableAdicional.Tipo AND AsientoContable.IdTransaccion = AsientoContableAdicional.IdTransaccionPoliza
                WHERE AsientoContable.EsValida = 1 AND AsientoContable.IdPeriodo = @IdPeriodo AND AsientoContable.IdListaDpoliza = @IdListaDpoliza
                ORDER BY AsientoContable.IdPeriodo,
                    AsientoContable.IdListaDpoliza,
                    AsientoContable.Partida;

                /*GENERAMOS LOS MOV. INTERSUCURSAL*/
                EXECUTE dbo.pCNTgenerarMovimientosInterSucursalPoliza @IdPolizaE = @IdPolizaE;

                -- int

                /*Agregamos pólizaR y acumulados contables*/
                DECLARE @TipoOper AS INT = IIF(@NoAcumular = 1, 4, 7);

                EXEC dbo.pCNTpolizasR @TipoOperacion = @TipoOper,
                    @IdPolizaE = @IdPolizaE;

                PRINT 'UPDATE';

                UPDATE Operacion
                SET TienePoliza = 1,
                    IdPolizaE = @IdPolizaE
                FROM dbo.tGRLoperaciones Operacion
                INNER JOIN #tmpAsientosOperaciones t ON t.IdOperacion = Operacion.IdOperacion
                WHERE Operacion.IdOperacion > 0 AND t.IdPeriodo = @IdPeriodo AND t.IdListaDpoliza = @IdListaDpoliza AND t.IdOperacion <> 0;

                --operaciones faltantes hijas
                UPDATE Operacion
                SET TienePoliza = 1,
                    IdPolizaE = @IdPolizaE
                FROM dbo.tGRLoperaciones Operacion
                INNER JOIN #tmpAsientosOperaciones t ON t.IdOperacion = Operacion.IdOperacionPadre
                WHERE Operacion.IdOperacion > 0 AND t.IdPeriodo = @IdPeriodo AND t.IdListaDpoliza = @IdListaDpoliza AND t.IdOperacion <> 0 AND Operacion.IdPolizaE = 0;
            END;

            FETCH NEXT FROM curPolizaE
            INTO @fecha,
                @Concepto,
                @IdListaDpoliza,
                @IdEjercicio,
                @IdPeriodo,
                @IdSucursal,
                @IdTipoDorigen,
                @Idestatus;
        END;

        CLOSE curPolizaE;
        DEALLOCATE curPolizaE;

        SET @IdEstatusPoliza = 1;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    END TRY
    BEGIN CATCH
        DECLARE @idtipox AS INT = (SELECT TOP(1)o.IdTipoOperacion
                                   FROM dbo.tGRLoperaciones o WITH(NOLOCK)
                                   WHERE o.IdOperacion = @IdOperacion AND @IdCierre = 0);

        IF(@idtipox = 25)
        BEGIN
            RETURN -1;
        END;

        SET @IdEstatusPoliza = 34;
        SET @Mensaje = (SELECT CONCAT ('CodEx|01944|pAYCejecutarProvisionAcreedoras|', ' ERROR_NUMBER: ', ERROR_NUMBER (), ' ERROR_SEVERITY: ', ERROR_SEVERITY (), ' ERROR_STATE: ', ERROR_STATE (), ' ERROR_PROCEDURE: ', ERROR_PROCEDURE (), ' ERROR_LINE: ', ERROR_LINE (), ' ERROR_MESSAGE', ERROR_MESSAGE ()));

        BEGIN TRY
            CLOSE curPolizaE;
            DEALLOCATE curPolizaE;
        END TRY
        BEGIN CATCH
        END CATCH;

        RAISERROR (@Mensaje, 16, 8);
    END CATCH;
END;
GO

/*FIX QUE CORRIGE EL IVA EN POLIZASD TRANSACCIONES FINANCIERAS*/

UPDATE PolizaD
SET PolizaD.BaseIVA = CASE Impuesto.TasaIVA WHEN 0 THEN
                                                 0
                                            ELSE CASE AsientoD.Campo WHEN 'InteresOrdinarioPagado' THEN
                                                                          Transaccion.InteresOrdinarioPagado
                                                                     WHEN 'InteresOrdinarioPagadoVencido' THEN
                                                                          Transaccion.InteresOrdinarioPagadoVencido
                                                                     WHEN 'InteresMoratorioPagado' THEN
                                                                          Transaccion.InteresMoratorioPagado
                                                                     WHEN 'InteresMoratorioPagadoVencido' THEN
                                                                          Transaccion.InteresMoratorioPagadoVencido
                                                                     ELSE 0
                                                 END
                      END,
    PolizaD.IVA = CASE AsientoD.Campo WHEN 'InteresOrdinarioPagado' THEN
                                           ROUND (Transaccion.InteresOrdinarioPagado * Impuesto.TasaIVA, 2)
                                      WHEN 'InteresOrdinarioPagadoVencido' THEN
                                           ROUND (Transaccion.InteresOrdinarioPagadoVencido * Impuesto.TasaIVA, 2)
                                      WHEN 'InteresMoratorioPagado' THEN
                                           ROUND (Transaccion.InteresMoratorioPagado * Impuesto.TasaIVA, 2)
                                      WHEN 'InteresMoratorioPagadoVencido' THEN
                                           ROUND (Transaccion.InteresMoratorioPagadoVencido * Impuesto.TasaIVA, 2)
                                      ELSE 0
                  END,
    PolizaD.TasaIVA = Impuesto.TasaIVA
FROM dbo.tCNTpolizasD PolizaD
INNER JOIN dbo.tSDOtransaccionesFinancieras Transaccion ON Transaccion.IdTransaccion = PolizaD.IdTransaccionFinanciera
INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Transaccion.IdImpuesto
INNER JOIN dbo.tCNTasientosD AsientoD ON AsientoD.IdAsientoD = PolizaD.IdAsientoD
WHERE Transaccion.IdImpuesto = 1 AND Transaccion.IdEstatus = 1 AND PolizaD.IdTransaccionFinanciera > 0 AND AsientoD.IdTipoDDominio = 143 AND AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido');

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  20/09/2021
=============================================*/
/*MEJORA A LA CONSULTA DE INGRESOS COBRADOS*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pDnFNZingresosPeriodo'))
DROP PROCEDURE pDnFNZingresosPeriodo
GO

CREATE PROCEDURE dbo.pDnFNZingresosPeriodo
@Periodo VARCHAR(8) = ''
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SET NOCOUNT ON;

    DECLARE @IdPeriodo INT;

    SELECT @IdPeriodo = IdPeriodo
    FROM dbo.tCTLperiodos WITH(NOLOCK)
    WHERE Codigo = @Periodo;

    SELECT Periodo.Codigo AS Período,
        TipoPoliza.Codigo AS [Tipo de Póliza],
        Poliza.Folio AS [Folio Póliza],
        Poliza.Fecha,
        TipoOperacion = TipoOperacion.Descripcion,
        Folio = CONCAT (Operacion.Serie, Operacion.Folio),
        TipoAIC.Descripcion AS Clasificación,
        AsientoD.Campo,
        CuentaContable.Codigo AS [Cuenta Contable],
        CuentaContable.Descripcion AS [Descripción],
        PolizaD.Concepto,
        PolizaD.Referencia,
        [Tipo Ingreso] = BienServicio.Descripcion,
        PolizaD.Abono - PolizaD.Cargo AS Importe,
        PolizaD.TasaIVA,
        PolizaD.IVA,
        Persona.Nombre AS [Socio/cliente],
        Persona.RFC,
        División = Division.Descripcion,
        Sucursal = Sucursal.Descripcion,
        Crédito = CONCAT (Cuenta.Descripcion, ' ', Cuenta.Codigo)
    FROM dbo.tCNTpolizasE Poliza WITH(NOLOCK)
    INNER JOIN dbo.tCATlistasD TipoPoliza WITH(NOLOCK)ON TipoPoliza.IdListaD = Poliza.IdListaDpoliza
    INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK)ON Periodo.IdPeriodo = Poliza.IdPeriodo
    INNER JOIN dbo.tCNTpolizasD PolizaD WITH(NOLOCK)ON Poliza.IdPolizaE = PolizaD.IdPolizaE
    INNER JOIN dbo.tCNTasientosD AsientoD WITH(NOLOCK)ON AsientoD.IdAsientoD = PolizaD.IdAsientoD
    INNER JOIN dbo.tGRLoperaciones Operacion WITH(NOLOCK)ON Operacion.IdOperacion = PolizaD.IdOperacion
    INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH(NOLOCK)ON TipoOperacion.IdTipoOperacion = Operacion.IdTipoOperacion
    INNER JOIN dbo.tCNTcuentas CuentaContable WITH(NOLOCK)ON CuentaContable.IdCuentaContable = PolizaD.IdCuentaContable
    INNER JOIN dbo.tAYCcuentas Cuenta WITH(NOLOCK)ON Cuenta.IdCuenta = PolizaD.IdCuenta
    INNER JOIN dbo.tCTLtiposD TipoAIC WITH(NOLOCK)ON TipoAIC.IdTipoD = Cuenta.IdTipoDAIC
    INNER JOIN dbo.tGRLpersonas Persona WITH(NOLOCK)ON Persona.IdPersona = PolizaD.IdPersona
    INNER JOIN dbo.tCNTdivisiones Division WITH(NOLOCK)ON Division.IdDivision = PolizaD.IdDivision
    INNER JOIN dbo.tSDOtransaccionesFinancieras TransaccionFinanciera WITH(NOLOCK)ON TransaccionFinanciera.IdTransaccion = PolizaD.IdTransaccionFinanciera
    INNER JOIN dbo.tGRLoperacionesD OperacionD WITH(NOLOCK)ON OperacionD.IdOperacionD = PolizaD.IdOperacionDOrigen
    INNER JOIN dbo.tCTLsucursales Sucursal WITH(NOLOCK)ON Sucursal.IdSucursal = PolizaD.IdSucursal
    INNER JOIN dbo.tIMPimpuestos ImpuestoOperacionD WITH(NOLOCK)ON ImpuestoOperacionD.IdImpuesto = OperacionD.IdImpuesto
    INNER JOIN dbo.tIMPimpuestos ImpuestoTransaccionFinanciera WITH(NOLOCK)ON ImpuestoTransaccionFinanciera.IdImpuesto = TransaccionFinanciera.IdImpuesto
    INNER JOIN dbo.tGRLbienesServicios BienServicio WITH(NOLOCK)ON BienServicio.IdBienServicio = CASE WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN
                                                                                                           -2019
                                                                                                      WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN
                                                                                                           -2020
                                                                                                      ELSE PolizaD.IdBienServicio
                                                                                                 END
    WHERE Poliza.IdPeriodo = @IdPeriodo AND Poliza.IdEstatus = 1 AND ((AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') AND AsientoD.IdTipoDDominio = 143) OR (AsientoD.IdTipoDRubro = 2726 OR AsientoD.Campo IN ('Subtotal') AND AsientoD.IdTipoOperacion = 17)) AND AsientoD.IdTipoDRubro NOT IN (1868, 1869, 1870, 1871);
END;
GO

