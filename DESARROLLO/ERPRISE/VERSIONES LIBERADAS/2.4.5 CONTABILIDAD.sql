IF NOT EXISTS (SELECT 1
               FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'tGRLOperacionesCuentasOrden' AND COLUMN_NAME = 'IdOperacionD')
BEGIN
    ALTER TABLE dbo.tGRLOperacionesCuentasOrden
    ADD IdOperacionD INT NOT NULL DEFAULT 0 CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdOperacionD] FOREIGN KEY (IdOperacionD) REFERENCES dbo.tGRLoperacionesD (IdOperacionD);
END;
GO


ALTER PROCEDURE dbo.pIMPgenerarOperacionesDIngresosGastosPagados
    @IdOperacion INT = NULL
AS
-- 
BEGIN
    SET NOCOUNT ON;

    SET XACT_ABORT ON;

    INSERT INTO dbo.tGRLOperacionesCuentasOrden (IdOperacion, IdTipoDdominio, IdTipoOperacion, IdEstatusDominio, Valor, BaseIVA, IVA, TasaIVA, TasaRetencionIVA, TasaRetencionISR, Concepto, Referencia, IdPersona, IdSocio, IdCuenta, IdBienServicio, IdCentroCostos, IdDivision, IdProyecto, IdAlmacen, IdCuentaABCD, IdDivisa, IdEntidad1, IdEntidad2, IdEntidad3, IdActivo, IdImpuesto, IdSucursal, IdEstructuraContableE, IdOperacionD)
    SELECT Transaccion.IdOperacion,
           Partida.IdTipoDDominioDestino,
           IdTipoOperacion = CASE Transaccion.IdTipoDDominioDestino WHEN 136 THEN 538
                                                                    WHEN 137 THEN 539
                                                                    WHEN 700 THEN 539
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
           Partida.IdEstructuraContableE,
           Partida.IdOperacionD
    FROM dbo.tSDOtransacciones Transaccion WITH (NOLOCK)
    INNER JOIN dbo.tSDOsaldos Saldo WITH (NOLOCK) ON Saldo.IdSaldo = Transaccion.IdSaldoDestino AND Transaccion.IdTipoSubOperacion = 502
    INNER JOIN dbo.tGRLoperaciones OperacionFactura WITH (NOLOCK) ON OperacionFactura.IdOperacion = Saldo.IdOperacion
    INNER JOIN dbo.tGRLoperacionesD Partida WITH (NOLOCK) ON OperacionFactura.IdOperacion = Partida.RelOperacionD
    INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Partida.IdImpuesto
    WHERE Saldo.IdTipoDDominioCatalogo <> 700 AND Transaccion.IdEstatus = 1 AND OperacionFactura.IdOperacion <> 0 AND Transaccion.IdOperacion = @IdOperacion AND NOT EXISTS (SELECT 1
                                                                                                                                                                             FROM dbo.tGRLOperacionesCuentasOrden CuentaOrden WITH (NOLOCK)
                                                                                                                                                                             WHERE Transaccion.IdOperacion = CuentaOrden.IdOperacion);
END;
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID ('vCNToperacionesCuentasOrden'))
    DROP VIEW dbo.vCNToperacionesCuentasOrden;
GO


CREATE VIEW dbo.vCNToperacionesCuentasOrden
AS
SELECT CuentaOrden.IdOperacionCuentasOrden,
       CuentaOrden.IdOperacion,
       CuentaOrden.IdTipoDdominio,
       CuentaOrden.IdTipoOperacion,
       CuentaOrden.IdEstatusDominio,
       CuentaOrden.Valor,
       CuentaOrden.BaseIVA,
       CuentaOrden.IVA,
       CuentaOrden.TasaIVA,
       CuentaOrden.TasaRetencionIVA,
       CuentaOrden.TasaRetencionISR,
       CuentaOrden.Concepto,
       CuentaOrden.Referencia,
       CuentaOrden.IdPersona,
       CuentaOrden.IdSocio,
       CuentaOrden.IdCuenta,
       CuentaOrden.IdBienServicio,
       CuentaOrden.IdCentroCostos,
       CuentaOrden.IdDivision,
       CuentaOrden.IdProyecto,
       CuentaOrden.IdAuxiliar,
       CuentaOrden.IdAlmacen,
       CuentaOrden.IdCuentaABCD,
       CuentaOrden.IdDivisa,
       CuentaOrden.IdEntidad1,
       CuentaOrden.IdEntidad2,
       CuentaOrden.IdEntidad3,
       CuentaOrden.IdActivo,
       CuentaOrden.IdImpuesto,
       CuentaOrden.IdSucursal,
       CuentaOrden.IdEstructuraContableE,
       Operacion.IdEstatus,
       Operacion.IdPeriodo,
       Operacion.IdListaDPoliza,
       Operacion.TienePoliza,
       OperacionIdCierre = Operacion.IdCierre,
       CuentaOrden.IdOperacionD
FROM dbo.tGRLOperacionesCuentasOrden CuentaOrden
INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion = CuentaOrden.IdOperacion
WHERE CuentaOrden.IdOperacionCuentasOrden <> 0;
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID ('pCNTgenerarCadenaAsientos'))
    DROP PROCEDURE dbo.pCNTgenerarCadenaAsientos;
GO


CREATE PROC [dbo].[pCNTgenerarCadenaAsientos]
    @Tipo INT,
    @TipoFiltro INT,
    @Credito BIT,
    @IdOperacion INT,
    @sql AS VARCHAR(MAX) = '' OUTPUT,
    @MostrarPoliza BIT = 0
AS
BEGIN
    -- VERSION 2.1.3
    DECLARE @FiltroMostrar VARCHAR(100) = IIF(@MostrarPoliza = 0, ' AND TienePoliza = 0 ', '');
    DECLARE @filtro VARCHAR(MAX) = CONCAT ('WHERE ', (SELECT CASE WHEN @TipoFiltro = 2 THEN ' OperacionIdCierre' ELSE 'IdOperacion' END), ' = ', @IdOperacion);
    DECLARE @CaseCampoValor AS VARCHAR(MAX) = '(CASE ';
    DECLARE @Select AS VARCHAR(MAX);
    DECLARE @tmp VARCHAR(MAX) = '';

    -- transacciones
    IF (@Tipo = 1)
    BEGIN

        --SE AGREGA EL IDESTATUS DOMINIO PARA LA SECCIÓN DE ACTIVOS PENDIENTS DE CLASIFICAR
        SET @tmp = CONCAT ('		SELECT *	
										FROM (	SELECT	Tipo = 1, v.IdOperacion, v.OperacionIdCierre, v.OperacionIdCorte, v.IdPeriodo, v.IdListaDPoliza, v.IdTransaccion, v.IdTipoOperacion, v.IdTipoSubOperacion, v.IdTipoDDominioSubOperacion, v.NaturalezaSaldo, v.IdTipoDDominio, 
														Monto =(CASE	WHEN Campo = ''DeSalvoBuenCobro''		THEN DeSalvoBuenCobro 
																		WHEN Campo = ''MontoSubOperacion''		THEN MontoSubOperacion 
																		WHEN Campo = ''SalvoBuenCobro''			THEN SalvoBuenCobro 
																		WHEN Campo = ''TotalAbonos''			THEN TotalAbonos 
																		WHEN Campo = ''TotalCargos''			THEN TotalCargos END), IdSucursal, vp.IdAsientoD,IdTipoSubOperacionA=v.IdTipoSubOperacion,IdTipoDDominioSubOperacionA=vp.IdTipoDDominioSubOperacion,NaturalezaA = vp.Naturaleza
												FROM vCNTtransacciones v
												JOIN vCNTasientosDpolizas vp ON vp.IdEstatus=1 AND NOT v.Idestatus in (18)  AND vp.Origen = ''Transaccion''
																				AND (vp.IdTipoDDominio = v.IdTipoDDominio OR vp.IdTipoDDominio = 0)														
																				AND (v.IdTipoSubOperacion=vp.IDTipoOperacion OR vp.IdTipoOperacion=0)
																				AND (v.IdTipoDDominioSubOperacion = vp.IdTipoDDominioSubOperacion OR vp.IdTipoDDominioSubOperacion = 0)
												', @filtro, @FiltroMostrar, ' ) AS con
										WHERE con.Monto <> 0');
    END;

    -- Transacciones Financieras
    IF (@Tipo = 2)
    BEGIN
        --Se omiten las canceladas y las salvobuencobro			
        IF (@Credito = 1)
        BEGIN
            SET @CaseCampoValor = 'CASE ';

            SELECT @CaseCampoValor = CONCAT (@CaseCampoValor, 'WHEN Campo = ''', ap.Campo, ''' THEN ', ap.Campo, ' ', CHAR (10))
            FROM dbo.vCNTasientosDpolizas ap
            WHERE ap.Origen = 'TFinanciera' AND ap.IdEstatus = 1 AND ap.IdTipoDDominio = 143 AND ((@TipoFiltro = 2 AND NOT IdTipoOperacion IN (6, 14)) OR (@TipoFiltro = 1))
            GROUP BY ap.Campo;

            SELECT @Select = CONCAT ('

								SELECT *	
								FROM (
 
								SELECT Tipo = 2, IdOperacion, OperacionIdCierre, OperacionIdCorte, IdPeriodo, IdListaDPoliza, IdTransaccion, v.IdTipoOperacion, IdTipoSubOperacion, v.IdTipoDDominioSubOperacion, v.IdTipoDDominio, v.IdEstatusDominio,
								Monto =(', CONCAT (@CaseCampoValor, ' END'), '),  IdSucursal,IdAsientoD = vp.IdAsientoD,IdTipoOperacionA = vp.IdTipoOperacion,IdTipoDDominioSubOperacionA=vp.IdTipoDDominioSubOperacion, IdEstatusDominioA  = vp.IdEstatusDominio
								FROM vCNTtransaccionesF v
								INNER JOIN vCNTasientosDpolizas vp ON vp.IdEstatus=1 AND NOT v.Idestatus in (18,31,25,43) AND vp.IdTipoDdominio=143 AND vp.Origen = ''TFinanciera''
															AND (vp.IdTipoDDominio = v.IdTipoDDominio OR vp.IdTipoDDominio = 0)
															AND (v.IdEstatusDominio=vp.IdEstatusDominio OR vp.IdEstatusDominio=0)
															AND (v.IdTipoSubOperacion=vp.IDTipoOperacion OR vp.IdTipoOperacion=0)
								', @filtro, @FiltroMostrar, '
								) AS con
								WHERE con.Monto<>0');

            SET @tmp = @Select;
        END;
        ELSE
        BEGIN
            SET @CaseCampoValor = 'CASE ';

            SELECT @CaseCampoValor = CONCAT (@CaseCampoValor, 'WHEN Campo = ''', ap.Campo, ''' THEN ', ap.Campo, ' ', CHAR (10))
            FROM dbo.vCNTasientosDpolizas ap
            WHERE ap.Origen = 'TFinanciera' AND ap.IdEstatus = 1 AND ap.IdTipoDDominio <> 143
            GROUP BY ap.Campo;

            SELECT @Select = CONCAT ('

								SELECT *	
								FROM (
 
								SELECT Tipo = 2, IdOperacion, OperacionIdCierre, OperacionIdCorte, IdPeriodo, IdListaDPoliza, IdTransaccion, v.IdTipoOperacion, IdTipoSubOperacion, v.IdTipoDDominioSubOperacion, v.IdTipoDDominio, v.IdEstatusDominio,
								Monto =(', CONCAT (@CaseCampoValor, ' END'), '),  IdSucursal,IdAsientoD = vp.IdAsientoD,IdTipoOperacionA = vp.IdTipoOperacion,IdTipoDDominioSubOperacionA=vp.IdTipoDDominioSubOperacion, IdEstatusDominioA  = vp.IdEstatusDominio
								FROM vCNTtransaccionesF v
								INNER JOIN vCNTasientosDpolizas vp ON vp.IdEstatus=1 AND NOT v.Idestatus in (18,31,25,43) AND vp.IdTipoDdominio<>143 AND v.IdTipoDdominio<>143 AND vp.Origen = ''TFinanciera''
															AND (vp.IdTipoDDominio = v.IdTipoDDominio OR vp.IdTipoDDominio = 0)
															AND (v.IdEstatusDominio=vp.IdEstatusDominio OR vp.IdEstatusDominio=0)
															AND (v.IdTipoSubOperacion=vp.IDTipoOperacion OR vp.IdTipoOperacion=0)
															AND (vp.Naturaleza = v.Naturaleza OR vp.Naturaleza = 0)
								', @filtro, @FiltroMostrar, '
								) AS con
								WHERE con.Monto<>0');

            SET @tmp = @Select;
        END;
    END;

    IF (@Tipo = 3) --OPERACIONES D
    BEGIN
        SET @tmp = CONCAT ('		SELECT *	
									FROM (		SELECT	Tipo = 3, v.IdOperacion, v.OperacionIdCierre, v.OperacionIdCorte, v.IdPeriodo, v.IdListaDPoliza, IdTransaccion = v.IdOperacionD, v.IdTipoOperacion, v.IdTipoSubOperacion, v.IdTipoDDominioSubOperacion, IdTipoDDominio = v.IdTipoDDominioDestino, v.IdEstatusDominio,
																Monto =(CASE WHEN Campo = ''IEPS''			THEN IEPS WHEN Campo = ''IVA''						THEN IVA
																 WHEN Campo = ''ImporteDeduccionExento''	THEN ImporteDeduccionExento WHEN Campo = ''ImporteDeduccionGravado''THEN ImporteDeduccionGravado 
																 WHEN Campo = ''ImporteExento''				THEN ImporteExento WHEN Campo = ''ImporteGravado''	THEN ImporteGravado 
																 WHEN Campo = ''Impuesto1''					THEN Impuesto1 WHEN Campo = ''Impuesto2''			THEN Impuesto2																 
																 WHEN Campo = ''RetencionImpuesto1''		THEN RetencionImpuesto1 WHEN Campo = ''RetencionImpuesto2''	THEN RetencionImpuesto2 
																 WHEN Campo = ''RetencionISR''				THEN RetencionISR WHEN Campo = ''RetencionIVA''		THEN RetencionIVA 
																 WHEN Campo = ''Salida''					THEN Salida WHEN Campo = ''CostoTotal''				THEN CostoTotal  WHEN Campo = ''Subtotal'' THEN Subtotal 																
																 WHEN Campo = ''Generado''					THEN Generado 
																 WHEN Campo = ''Pagado'' THEN Pagado
																 WHEN Campo = ''EstimacionCargo'' THEN EstimacionCargo
																 WHEN Campo = ''EstimacionAbono'' THEN EstimacionAbono
																 END), IdSucursal, vp.IdAsientoD, IdTipoSubOperacionA =  vp.IdTipoOperacion, IdEstatusDominioA  = vp.IdEstatusDominio
													FROM vCNToperacionesD v
													INNER JOIN vCNTasientosDpolizas vp ON vp.IdEstatus=1 AND NOT v.Idestatus IN (18)  AND vp.Origen = ''Partida''																										
																				AND (v.IdTipoSubOperacion=vp.IDTipoOperacion OR vp.IdTipoOperacion=0)
																				AND (v.IdTipoDDominioSubOperacion = vp.IdTipoDDominioSubOperacion OR vp.IdTipoDDominioSubOperacion = 0)
																				AND (v.IdTipoDDominioDestino = vp.IdTipoDDominio   OR vp.IdTipoDDominio   = 0)
																				AND (v.IdEstatusDominio      = vp.IdEstatusDominio OR vp.IdEstatusDominio = 0)
										', @filtro, @FiltroMostrar, ' ) AS con
										WHERE con.Monto <>0 ');
    END;

    IF (@Tipo = 4) --IMPUESTOS
    BEGIN
        --OPCION PARA OPERACIONES
        IF (@TipoFiltro = 1)
        BEGIN
            INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA, Naturaleza, NaturalezaA)
            SELECT con.Tipo,
                   con.IdOperacion,
                   con.OperacionIdCierre,
                   con.OperacionIdCorte,
                   con.IdPeriodo,
                   con.IdListaDPoliza,
                   con.IdTransaccion,
                   con.IdTipoOperacion,
                   con.IdTipoSubOperacion,
                   con.IdTipoDDominioSubOperacion,
                   con.IdTipoDDominio,
                   con.IdEstatusDominio,
                   con.Monto,
                   con.IdSucursal,
                   con.IdAsientoD,
                   con.IdTipoSubOperacionA,
                   con.IdEstatusDominioA,
                   con.Naturaleza,
                   con.NaturalezaA
            FROM (SELECT Tipo = 4,
                         TransaccionImpuesto.IdOperacion,
                         TransaccionImpuesto.OperacionIdCierre,
                         TransaccionImpuesto.OperacionIdCorte,
                         TransaccionImpuesto.IdPeriodo,
                         TransaccionImpuesto.IdListaDPoliza,
                         IdTransaccion = TransaccionImpuesto.IdTransaccionImpuesto,
                         TransaccionImpuesto.IdTipoOperacion,
                         TransaccionImpuesto.IdTipoSubOperacion,
                         TransaccionImpuesto.IdTipoDDominioSubOperacion,
                         IdTipoDDominio = 0,
                         TransaccionImpuesto.IdEstatusDominio,
                         Monto = (CASE WHEN AsientoPoliza.Campo = 'DeIVAefectivamentePagado' THEN TransaccionImpuesto.DeIVAefectivamentePagado
                                       WHEN AsientoPoliza.Campo = 'DeIVAgenerado' THEN TransaccionImpuesto.DeIVAgenerado
                                       WHEN AsientoPoliza.Campo = 'DeIVApagado' THEN TransaccionImpuesto.DeIVAPagado
                                       WHEN AsientoPoliza.Campo = 'IVAefectivamentePagado' THEN TransaccionImpuesto.IVAEfectivamentePagado
                                       WHEN AsientoPoliza.Campo = 'IVAgenerado' THEN TransaccionImpuesto.IVAgenerado
                                       WHEN AsientoPoliza.Campo = 'IVApagado' THEN TransaccionImpuesto.IVApagado
                                       ELSE NULL
                                  END),
                         TransaccionImpuesto.IdSucursal,
                         AsientoPoliza.IdAsientoD,
                         IdTipoSubOperacionA = AsientoPoliza.IdTipoOperacion,
                         IdEstatusDominioA = AsientoPoliza.IdEstatusDominio,
                         TransaccionImpuesto.Naturaleza,
                         NaturalezaA = AsientoPoliza.Naturaleza
                  FROM dbo.vCNTtransaccionesImpuestos TransaccionImpuesto
                  JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdEstatus = 1 AND NOT TransaccionImpuesto.IdEstatus IN (18, 31, 25, 43) AND AsientoPoliza.IdTipoDDominio <> 143 AND AsientoPoliza.Origen = 'iTransaccion' AND (AsientoPoliza.Naturaleza = TransaccionImpuesto.Naturaleza OR AsientoPoliza.Naturaleza = 0)
                  WHERE TransaccionImpuesto.IdOperacion = @IdOperacion) AS con
            WHERE con.Monto <> 0;
        END;
        ELSE
        --OPCIÓN PARA CIERRES
        BEGIN
            --PRINT 'good z'		
            INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA, Naturaleza, NaturalezaA)
            SELECT con.Tipo,
                   con.IdOperacion,
                   con.OperacionIdCierre,
                   con.OperacionIdCorte,
                   con.IdPeriodo,
                   con.IdListaDPoliza,
                   con.IdTransaccion,
                   con.IdTipoOperacion,
                   con.IdTipoSubOperacion,
                   con.IdTipoDDominioSubOperacion,
                   con.IdTipoDDominio,
                   con.IdEstatusDominio,
                   con.Monto,
                   con.IdSucursal,
                   con.IdAsientoD,
                   con.IdTipoSubOperacionA,
                   con.IdEstatusDominioA,
                   con.Naturaleza,
                   con.NaturalezaA
            FROM (SELECT Tipo = 4,
                         TransaccionImpuesto.IdOperacion,
                         TransaccionImpuesto.OperacionIdCierre,
                         TransaccionImpuesto.OperacionIdCorte,
                         TransaccionImpuesto.IdPeriodo,
                         TransaccionImpuesto.IdListaDPoliza,
                         IdTransaccion = TransaccionImpuesto.IdTransaccionImpuesto,
                         TransaccionImpuesto.IdTipoOperacion,
                         TransaccionImpuesto.IdTipoSubOperacion,
                         TransaccionImpuesto.IdTipoDDominioSubOperacion,
                         IdTipoDDominio = 0,
                         TransaccionImpuesto.IdEstatusDominio,
                         Monto = (CASE WHEN AsientoPoliza.Campo = 'DeIVAefectivamentePagado' THEN TransaccionImpuesto.DeIVAefectivamentePagado
                                       WHEN AsientoPoliza.Campo = 'DeIVAgenerado' THEN TransaccionImpuesto.DeIVAgenerado
                                       WHEN AsientoPoliza.Campo = 'DeIVApagado' THEN TransaccionImpuesto.DeIVAPagado
                                       WHEN AsientoPoliza.Campo = 'IVAefectivamentePagado' THEN TransaccionImpuesto.IVAEfectivamentePagado
                                       WHEN AsientoPoliza.Campo = 'IVAgenerado' THEN TransaccionImpuesto.IVAgenerado
                                       WHEN AsientoPoliza.Campo = 'IVApagado' THEN TransaccionImpuesto.IVApagado
                                       ELSE NULL
                                  END),
                         TransaccionImpuesto.IdSucursal,
                         AsientoPoliza.IdAsientoD,
                         IdTipoSubOperacionA = AsientoPoliza.IdTipoOperacion,
                         IdEstatusDominioA = AsientoPoliza.IdEstatusDominio,
                         TransaccionImpuesto.Naturaleza,
                         NaturalezaA = AsientoPoliza.Naturaleza
                  FROM dbo.vCNTtransaccionesImpuestos TransaccionImpuesto
                  JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdEstatus = 1 AND NOT TransaccionImpuesto.IdEstatus IN (18, 31, 25, 43) AND AsientoPoliza.IdTipoDDominio <> 143 AND AsientoPoliza.Origen = 'iTransaccion' AND (AsientoPoliza.Naturaleza = TransaccionImpuesto.Naturaleza OR AsientoPoliza.Naturaleza = 0)
                  WHERE TransaccionImpuesto.OperacionIdCierre = @IdOperacion) AS con
            WHERE con.Monto <> 0;
        END;
    END;

    IF (@Tipo = 5) --GENERALES
    BEGIN
        --OPCION PARA OPERACIONES
        IF (@TipoFiltro = 1)
        BEGIN
            INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA)
            SELECT con.Tipo,
                   con.IdOperacion,
                   con.OperacionIdCierre,
                   con.OperacionIdCorte,
                   con.IdPeriodo,
                   con.IdListaDPoliza,
                   con.IdTransaccion,
                   con.IdTipoOperacion,
                   con.IdTipoSubOperacion,
                   con.IdTipoDDominioSubOperacion,
                   con.IdTipoDDominio,
                   con.IdEstatusDominio,
                   con.Monto,
                   con.IdSucursal,
                   con.IdAsientoD,
                   con.IdTipoSubOperacionA,
                   con.IdEstatusDominioA
            FROM (SELECT Tipo = 5,
                         Operacion.IdOperacion,
                         Operacion.OperacionIdCierre,
                         Operacion.OperacionIdCorte,
                         Operacion.IdPeriodo,
                         Operacion.IdListaDPoliza,
                         IdTransaccion = Operacion.IdOperacionTransaccion,
                         Operacion.IdTipoOperacion,
                         Operacion.IdTipoSubOperacion,
                         Operacion.IdTipoDDominioSubOperacion,
                         IdTipoDDominio = 0,
                         Operacion.IdEstatusDominio,
                         Operacion.Monto,
                         Operacion.IdSucursal,
                         AsientoPoliza.IdAsientoD,
                         IdTipoSubOperacionA = AsientoPoliza.IdTipoOperacion,
                         IdEstatusDominioA = AsientoPoliza.IdEstatusDominio
                  FROM dbo.vCNToperaciones Operacion
                  JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdEstatus = 1 AND AsientoPoliza.IdTipoDDominio <> 143 AND AsientoPoliza.Origen = 'General' AND Operacion.idTipoDRubro = AsientoPoliza.IdTipoDRubro
                  WHERE Operacion.IdOperacion = @IdOperacion) AS con
            WHERE con.Monto <> 0;
        END;
        ELSE
        --OPCIÓN PARA CIERRES
        BEGIN
            INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA)
            SELECT con.Tipo,
                   con.IdOperacion,
                   con.OperacionIdCierre,
                   con.OperacionIdCorte,
                   con.IdPeriodo,
                   con.IdListaDPoliza,
                   con.IdTransaccion,
                   con.IdTipoOperacion,
                   con.IdTipoSubOperacion,
                   con.IdTipoDDominioSubOperacion,
                   con.IdTipoDDominio,
                   con.IdEstatusDominio,
                   con.Monto,
                   con.IdSucursal,
                   con.IdAsientoD,
                   con.IdTipoSubOperacionA,
                   con.IdEstatusDominioA
            FROM (SELECT Tipo = 5,
                         Operacion.IdOperacion,
                         Operacion.OperacionIdCierre,
                         Operacion.OperacionIdCorte,
                         Operacion.IdPeriodo,
                         Operacion.IdListaDPoliza,
                         IdTransaccion = Operacion.IdOperacionTransaccion,
                         Operacion.IdTipoOperacion,
                         Operacion.IdTipoSubOperacion,
                         Operacion.IdTipoDDominioSubOperacion,
                         IdTipoDDominio = 0,
                         Operacion.IdEstatusDominio,
                         Operacion.Monto,
                         Operacion.IdSucursal,
                         AsientoPoliza.IdAsientoD,
                         IdTipoSubOperacionA = AsientoPoliza.IdTipoOperacion,
                         IdEstatusDominioA = AsientoPoliza.IdEstatusDominio
                  FROM dbo.vCNToperaciones Operacion
                  JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdEstatus = 1 AND AsientoPoliza.IdTipoDDominio <> 143 AND AsientoPoliza.Origen = 'General' AND Operacion.idTipoDRubro = AsientoPoliza.IdTipoDRubro
                  WHERE Operacion.OperacionIdCierre = @IdOperacion) AS con
            WHERE con.Monto <> 0;
        END;
    END;

    IF (@Tipo = 6) -- CUENTAS DE ORDEN
    BEGIN
        SET @tmp = CONCAT ('SELECT con.Tipo,
								   con.IdOperacion,
								   con.IdOperacionD,
								   con.IdPeriodo,
								   con.IdListaDPoliza,
								   con.IdTransaccion,
								   con.IdTipoOperacion,
								   con.IdTipoDdominio,
								   con.IdEstatusDominio,
								   con.Monto,
								   con.IdSucursal,
								   con.IdAsientoD,
								   con.IdTipoSubOperacionA,
								   con.IdEstatusDominioA
							FROM ( SELECT Tipo = 6,
										  Operacion.IdOperacion,
										  Operacion.IdOperacionD,
										  Operacion.IdPeriodo,
										  Operacion.IdListaDPoliza,
										  IdTransaccion = Operacion.IdOperacionCuentasOrden,
										  Operacion.IdTipoOperacion,
										  Operacion.IdTipoDdominio,
										  Operacion.IdEstatusDominio,
										  Monto = CASE WHEN AsientoContable.Campo = ''Valor'' THEN Operacion.Valor
													   ELSE NULL
												  END,
										  Operacion.IdSucursal,
										  AsientoContable.IdAsientoD,
										  IdTipoSubOperacionA = AsientoContable.IdTipoOperacion,
										  IdEstatusDominioA = AsientoContable.IdEstatusDominio
								   FROM dbo.vCNToperacionesCuentasOrden Operacion
								   INNER JOIN dbo.vCNTasientosDpolizas AsientoContable ON AsientoContable.IdEstatus = 1 AND NOT Operacion.IdEstatus = 18 AND AsientoContable.Origen = ''CuentaOrden'' 
																														AND Operacion.IdTipoOperacion = AsientoContable.IdTipoOperacion 
																														AND Operacion.IdTipoDdominio = AsientoContable.IdTipoDDominio
																	', @filtro, @FiltroMostrar, ' ) AS con
																	WHERE con.Monto <>0 ');
    END;

    IF (@tmp <> '')
    BEGIN
        SELECT @sql = @tmp;
    END;
END;
GO


IF EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID ('pCNTgenerarPolizaBaseDatos'))
    DROP PROCEDURE dbo.pCNTgenerarPolizaBaseDatos;
GO


CREATE PROC [dbo].[pCNTgenerarPolizaBaseDatos]
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
    @Recontabilizacion BIT = 0,
    @Mensaje AS VARCHAR(MAX) = '' OUTPUT,
    @MostrarInformacionUsuario AS BIT = 1
AS
--	VERSIÓN 2.1.3
BEGIN
    --Deshabilitamos la devolucion de los valores
    SET NOCOUNT ON;

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @Id INT = (CASE WHEN @TipoFiltro = 1 THEN @IdOperacion
                            ELSE @IdCierre
                       END);
    DECLARE @UsaMovimientoIntersucursal AS BIT = ISNULL ((SELECT TOP (1) IIF(Valor = 'true', 1, 0)
                                                          FROM dbo.tCTLconfiguracion WITH (NOLOCK)
                                                          WHERE IdConfiguracion = 17
                                                          ORDER BY IdConfiguracion), 0);

    IF OBJECT_ID ('tempdb..#tmpAsientosOperaciones') IS NULL
        CREATE TABLE #tmpAsientosOperaciones
        (
            IdOperacion INT NULL,
            IdEjercicio INT NULL,
            IdPeriodo INT NULL,
            IdListaDpoliza INT NULL,
            IdSucursal INT NULL,
            IdSucursalPrincipal INT NULL,
            Cargos NUMERIC(23, 8) NULL,
            Abonos NUMERIC(23, 8) NULL,
            EsValida BIT DEFAULT 0 NULL
        );

    IF OBJECT_ID ('tempdb..#tmpAsientosContableE') IS NULL
        CREATE TABLE #tmpAsientosContableE
        (
            Fecha DATE NULL,
            Concepto VARCHAR(300) NULL,
            IdListaDpoliza INT NULL,
            IdEjercicio INT NULL,
            IdPeriodo INT NULL,
            IdSucursal INT NULL,
            IdTipoDorigen INT DEFAULT 801 NULL,
            Idestatus INT DEFAULT 34 NULL
        );

    IF OBJECT_ID ('tempdb..#tmpAsientosContableD') IS NULL
        CREATE TABLE #tmpAsientosContableD
        (
            Id INT IDENTITY(1, 1),
            Tipo INT NULL,
            IdOperacion INT NULL,
            IdCierre INT NULL,
            IdCorte INT NULL,
            IdPeriodo INT NULL,
            IdListaDpoliza INT NULL,
            IdTransaccion INT NULL,
            IdTipoOperacion INT NULL,
            IdTipoSubOperacion INT NULL,
            IdTipoDDominioSubOperacion INT NULL,
            Naturaleza SMALLINT NULL,
            IdTipoDDominio INT NULL,
            IdEstatusDominio INT NULL,
            --para fines de redondeo le cambiamos a numeric 2
            valor NUMERIC(23, 2) NULL,
            IdSucursal INT NULL,
            idAsientoD INT NULL,
            IdTipoOperacionA INT NULL,
            IdTipoSubOperacionA INT NULL,
            IdTipoDDominioSubOperacionA INT NULL,
            NaturalezaA SMALLINT NULL,
            IdEstatusDominioA INT NULL,
            EsValida BIT DEFAULT 0 NULL,
            IdTipoDRubro INT NULL,
            EsImpuestos BIT NULL,
            IdEstructuraContableE INT NULL,
            IdCentroCostos INT DEFAULT 0 NULL,
            IdImpuesto INT NULL,
            IdDivisa INT NULL,
            IdDivision INT NULL,
            IdTipoDImpuesto INT NULL,
            IdAuxiliar INT NULL,
            IdBienServicio INT NULL,
            IdEstructuraContableD INT DEFAULT 0 NULL,
            IdCuentaContable INT DEFAULT 0 NULL,
            IdCuentaContableComplementaria INT NULL,
            EsCargo BIT NULL,
            Inverso BIT NULL,
            Partida INT NULL,
            Cargo NUMERIC(23, 8) NULL,
            Abono NUMERIC(23, 8) NULL,
            IdSucursalPrincipal INT NULL,
            IdOperacionD INT NULL,
            BaseIVA NUMERIC(18, 2) NULL,
            IVA NUMERIC(18, 2) NULL,
            TasaIVA NUMERIC(18, 2) NULL,
            TasaRetencionIVA NUMERIC(18, 2) NULL,
            TasaRetencionISR NUMERIC(18, 2) NULL,
            EsIntersucursal BIT NULL
        );

    IF OBJECT_ID ('tempdb..#tmpAsientosContableDatosAdicional') IS NULL
        CREATE TABLE #tmpAsientosContableDatosAdicional
        (
            Tipo INT DEFAULT 0 NULL,
            IdTransaccionPoliza INT DEFAULT 0 NULL,
            IdProyecto INT DEFAULT 0 NULL,
            IdCuenta INT DEFAULT 0 NULL,
            IdAuxiliar INT DEFAULT 0 NULL,
            IdEntidad1 INT DEFAULT 0 NULL,
            IdEntidad2 INT DEFAULT 0 NULL,
            IdEntidad3 INT DEFAULT 0 NULL,
            IdPersona INT DEFAULT 0 NULL,
            IdSocio INT DEFAULT 0 NULL,
            IdCliente INT DEFAULT 0 NULL,
            IdClienteFiscal INT DEFAULT 0 NULL,
            IdEmisorProveedor INT DEFAULT 0 NULL,
            IdProveedorFiscal INT DEFAULT 0 NULL,
            IdBienServicio INT DEFAULT 0 NULL,
            IdAlmacen INT DEFAULT 0 NULL,
            IdDivision INT DEFAULT 0 NULL,
            IdCuentaABCD INT DEFAULT 0 NULL,
            IdDivisa INT DEFAULT 0 NULL,
            IdOperacion INT DEFAULT 0 NULL,
            IdOperacionDOrigen INT DEFAULT 0 NULL,
            IdTransaccion INT DEFAULT 0 NULL,
            IdTransaccionFinanciera INT DEFAULT 0 NULL,
            IdSucursal INT DEFAULT 0 NULL,
            Concepto VARCHAR(80) DEFAULT '' NULL,
            Referencia VARCHAR(30) DEFAULT '' NULL,
            IdSaldoDestino INT DEFAULT 0 NULL,
            IdOperacionTransaccion INT DEFAULT 0 NULL,
            IdTransaccionImpuesto INT DEFAULT 0 NULL,
            IdOperacionCuentasOrden INT DEFAULT 0 NULL
        );

    INSERT INTO #tmpAsientosContableDatosAdicional
    DEFAULT VALUES;

    INSERT INTO #tmpAsientosContableE (IdEjercicio, IdPeriodo, IdSucursal, Fecha, IdListaDpoliza, Concepto)
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

        INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, Naturaleza, IdTipoDDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdTipoDDominioSubOperacionA, NaturalezaA)
        EXEC (@sql);

        UPDATE AsientoContable
        SET EsValida = 1
        FROM #tmpAsientosContableD AsientoContable
        WHERE Tipo = 1 AND ((AsientoContable.IdTipoSubOperacionA = 0) OR (AsientoContable.IdTipoSubOperacionA <> 0 AND AsientoContable.IdTipoSubOperacionA = AsientoContable.IdTipoSubOperacion)) AND ((AsientoContable.IdTipoDDominioSubOperacionA = 0) OR (AsientoContable.IdTipoDDominioSubOperacionA <> 0 AND AsientoContable.IdTipoDDominioSubOperacionA = AsientoContable.IdTipoDDominioSubOperacion)) AND ((NOT AsientoContable.IdTipoDDominio IN (136, 137, 700)) OR (AsientoContable.IdTipoDDominio IN (136, 137, 700) AND AsientoContable.NaturalezaA = AsientoContable.Naturaleza));

        -- clientes, proveedores, deudores

        --Actualizamos otros campos
        UPDATE AsientoContable
        SET IdPeriodo = Transacciones.IdPeriodo,
            Inverso = IIF(AsientoContable.valor < 0, 1, NULL),
            EsCargo = CASE WHEN AsientoContable.valor < 0 AND AsientosD.EsCargo = 1 THEN 0
                           WHEN AsientoContable.valor < 0 AND AsientosD.EsCargo = 0 THEN 1
                           ELSE AsientosD.EsCargo
                      END,
            IdEstructuraContableE = IIF(AsientosD.EsImpuestos = 1, Transacciones.IdEstructuraContableEimpuesto, Transacciones.IdEstructuraContableE),
            IdCentroCostos = Transacciones.IdCentroCostos,
            IdTipoDRubro = AsientosD.IdTipoDRubro,
            EsImpuestos = AsientosD.EsImpuestos,
            IdImpuesto = Transacciones.IdImpuesto,
            IdTipoDImpuesto = IIF(AsientosD.EsImpuestos = 1, AsientosD.IdTipoDImpuesto, NULL),
            IdDivisa = Transacciones.IdDivisa,
            IdAuxiliar = Transacciones.IdAuxiliar,
            IdOperacion = Transacciones.IdOperacion,
            IdSucursal = Transacciones.IdSucursal
        FROM #tmpAsientosContableD AsientoContable
        INNER JOIN dbo.vCNTasientosDpolizas AsientosD ON AsientosD.IdAsientoD = AsientoContable.idAsientoD
        INNER JOIN dbo.vCNTtransacciones Transacciones ON Transacciones.IdTransaccion = AsientoContable.IdTransaccion
        WHERE AsientoContable.Tipo = 1 AND AsientoContable.EsValida = 1;
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

        INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoOperacionA, IdTipoDDominioSubOperacionA, IdEstatusDominioA)
        EXEC (@sql);

        SET @sql = '';

        --asientosD para crédito
        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 2,
                                           @TipoFiltro = @TipoFiltro,
                                           @Credito = 1,
                                           @IdOperacion = @Id,
                                           @sql = @sql OUTPUT,
                                           @MostrarPoliza = @MostrarPoliza;

        INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoOperacionA, IdTipoDDominioSubOperacionA, IdEstatusDominioA)
        EXEC (@sql);

        UPDATE AsientoContable
        SET EsValida = 1
        FROM #tmpAsientosContableD AsientoContable
        WHERE Tipo = 2 AND (((AsientoContable.IdTipoOperacionA = 0) OR (IdTipoOperacionA <> 0 AND AsientoContable.IdTipoOperacionA = AsientoContable.IdTipoOperacion)) OR (AsientoContable.IdTipoOperacion = 41 AND AsientoContable.IdTipoSubOperacion = AsientoContable.IdTipoOperacionA AND AsientoContable.IdTipoOperacionA IN (6, 14))) AND ((AsientoContable.IdTipoDDominioSubOperacionA = 0) OR (AsientoContable.IdTipoDDominioSubOperacionA <> 0 AND AsientoContable.IdTipoDDominioSubOperacionA = AsientoContable.IdTipoDDominioSubOperacion)) AND ((AsientoContable.IdEstatusDominioA = 0) OR (AsientoContable.IdEstatusDominioA <> 0 AND AsientoContable.IdEstatusDominioA = AsientoContable.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE AsientoContable
        SET IdPeriodo = TransaccionFinanciera.IdPeriodo,
            Inverso = IIF(AsientoContable.valor < 0, 1, NULL),
            IdEstructuraContableE = IIF(AsientosD.EsImpuestos = 1, TransaccionFinanciera.IdEstructuraContableEimpuesto, TransaccionFinanciera.IdEstructuraContableE),
            IdCentroCostos = TransaccionFinanciera.IdCentroCostos,
            IdTipoDRubro = AsientosD.IdTipoDRubro,
            EsImpuestos = AsientosD.EsImpuestos,
            IdImpuesto = TransaccionFinanciera.IdImpuesto,
            IdTipoDImpuesto = IIF(AsientosD.EsImpuestos = 1, AsientosD.IdTipoDImpuesto, NULL),
            IdDivisa = TransaccionFinanciera.IdDivisa,
            IdDivision = TransaccionFinanciera.IdDivision,
            IdAuxiliar = TransaccionFinanciera.IdAuxiliar,
            IdSucursal = TransaccionFinanciera.IdSucursal,
            EsCargo = CASE WHEN AsientoContable.valor < 0 AND AsientosD.EsCargo = 1 THEN 0
                           WHEN AsientoContable.valor < 0 AND AsientosD.EsCargo = 0 THEN 1
                           ELSE AsientosD.EsCargo
                      END
        FROM #tmpAsientosContableD AsientoContable
        INNER JOIN dbo.vCNTasientosDpolizas AsientosD ON AsientosD.IdAsientoD = AsientoContable.idAsientoD
        INNER JOIN dbo.vCNTtransaccionesF TransaccionFinanciera ON TransaccionFinanciera.IdTransaccion = AsientoContable.IdTransaccion
        WHERE AsientoContable.Tipo = 2 AND AsientoContable.EsValida = 1;
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

        INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA)
        EXEC (@sql);

        UPDATE AsientoContable
        SET EsValida = 1
        FROM #tmpAsientosContableD AsientoContable
        WHERE Tipo = 3 AND ((AsientoContable.IdTipoSubOperacionA = 0 OR AsientoContable.IdTipoSubOperacionA = AsientoContable.IdTipoSubOperacion)) AND ((AsientoContable.IdEstatusDominioA = 0) OR (AsientoContable.IdEstatusDominioA <> 0 AND AsientoContable.IdEstatusDominioA = AsientoContable.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE AsientoContable
        SET IdPeriodo = OperacionD.IdPeriodo,
            Inverso = IIF(AsientoContable.valor < 0, 1, NULL),
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
            EsCargo = CASE WHEN AsientoContable.valor < 0 AND AsientoPoliza.EsCargo = 1 THEN 0
                           WHEN AsientoContable.valor < 0 AND AsientoPoliza.EsCargo = 0 THEN 1
                           ELSE AsientoPoliza.EsCargo
                      END
        FROM #tmpAsientosContableD AsientoContable
        INNER JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdAsientoD = AsientoContable.idAsientoD
        INNER JOIN dbo.vCNToperacionesD OperacionD ON OperacionD.IdOperacionD = AsientoContable.IdTransaccion
        WHERE AsientoContable.Tipo = 3 AND AsientoContable.EsValida = 1;
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

        UPDATE AsientoContable
        SET EsValida = 1
        FROM #tmpAsientosContableD AsientoContable
        WHERE Tipo = 4 AND ((AsientoContable.IdTipoSubOperacionA = 0 OR AsientoContable.IdTipoSubOperacionA = AsientoContable.IdTipoSubOperacion)) AND ((AsientoContable.IdEstatusDominioA = 0) OR (AsientoContable.IdEstatusDominioA <> 0 AND AsientoContable.IdEstatusDominioA = AsientoContable.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE AsientoContable
        SET IdPeriodo = TransaccionImpuesto.IdPeriodo,
            Inverso = IIF(AsientoContable.valor < 0, 1, NULL),
            IdEstructuraContableE = TransaccionImpuesto.IdEstructuraContableEimpuesto,
            IdCentroCostos = TransaccionImpuesto.IdCentroCostos,
            IdTipoDRubro = AsientoPoliza.IdTipoDRubro,
            EsImpuestos = AsientoPoliza.EsImpuestos,
            IdImpuesto = TransaccionImpuesto.IdImpuesto,
            IdTipoDImpuesto = AsientoPoliza.IdTipoDImpuesto,
            IdSucursal = TransaccionImpuesto.IdSucursal,
            EsCargo = CASE WHEN AsientoContable.valor < 0 AND AsientoPoliza.EsCargo = 1 THEN 0
                           WHEN AsientoContable.valor < 0 AND AsientoPoliza.EsCargo = 0 THEN 1
                           ELSE AsientoPoliza.EsCargo
                      END,
            BaseIVA = TransaccionImpuesto.BaseIVA,
            IVA = TransaccionImpuesto.IVA,
            TasaIVA = TransaccionImpuesto.TasaIVA,
            TasaRetencionIVA = TransaccionImpuesto.TasaRetencionIVA,
            TasaRetencionISR = TransaccionImpuesto.TasaRetencionISR
        FROM #tmpAsientosContableD AsientoContable
        INNER JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdAsientoD = AsientoContable.idAsientoD
        INNER JOIN dbo.vCNTtransaccionesImpuestos TransaccionImpuesto ON TransaccionImpuesto.IdTransaccionImpuesto = AsientoContable.IdTransaccion
        WHERE AsientoContable.Tipo = 4 AND AsientoContable.EsValida = 1;
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

        UPDATE AsientoContable
        SET EsValida = 1
        FROM #tmpAsientosContableD AsientoContable
        WHERE Tipo = 5 AND ((AsientoContable.IdTipoSubOperacionA = 0 OR AsientoContable.IdTipoSubOperacionA = AsientoContable.IdTipoSubOperacion)) AND ((AsientoContable.IdEstatusDominioA = 0) OR (AsientoContable.IdEstatusDominioA <> 0 AND AsientoContable.IdEstatusDominioA = AsientoContable.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE AsientoContable
        SET IdPeriodo = Operacion.IdPeriodo,
            Inverso = IIF(AsientoContable.valor < 0, 1, NULL),
            IdEstructuraContableE = Operacion.IdEstructuraContableE,
            IdCentroCostos = Operacion.IdCentroCostos,
            IdTipoDRubro = AsientoPoliza.IdTipoDRubro,
            EsImpuestos = 0,
            IdImpuesto = 0,
            IdTipoDImpuesto = 0,
            IdSucursal = Operacion.IdSucursal,
            EsCargo = CASE WHEN AsientoContable.valor < 0 AND AsientoPoliza.EsCargo = 1 THEN 0
                           WHEN AsientoContable.valor < 0 AND AsientoPoliza.EsCargo = 0 THEN 1
                           ELSE AsientoPoliza.EsCargo
                      END
        FROM #tmpAsientosContableD AsientoContable
        JOIN dbo.vCNTasientosDpolizas AsientoPoliza ON AsientoPoliza.IdAsientoD = AsientoContable.idAsientoD
        JOIN dbo.vCNToperaciones Operacion ON Operacion.IdOperacionTransaccion = AsientoContable.IdTransaccion
        WHERE AsientoContable.Tipo = 5 AND AsientoContable.EsValida = 1;
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

        INSERT INTO #tmpAsientosContableD (Tipo, IdOperacion, IdOperacionD, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA)
        EXEC (@sql);

        UPDATE AsientoContable
        SET EsValida = 1
        FROM #tmpAsientosContableD AsientoContable
        WHERE Tipo = 6 AND ((AsientoContable.IdTipoSubOperacionA = 0 OR AsientoContable.IdTipoSubOperacionA = AsientoContable.IdTipoOperacion)) AND ((AsientoContable.IdEstatusDominioA = 0) OR (AsientoContable.IdEstatusDominioA <> 0 AND AsientoContable.IdEstatusDominioA = AsientoContable.IdEstatusDominio));

        --Actualizamos otros campos
        UPDATE AsientoContable
        SET IdPeriodo = CuentasOrden.IdPeriodo,
            Inverso = IIF(AsientoContable.valor < 0, 1, NULL),
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
            EsCargo = CASE WHEN AsientoContable.valor < 0 AND AsientoD.EsCargo = 1 THEN 0
                           WHEN AsientoContable.valor < 0 AND AsientoD.EsCargo = 0 THEN 1
                           ELSE AsientoD.EsCargo
                      END,
            AsientoContable.BaseIVA = CuentasOrden.BaseIVA,
            AsientoContable.IVA = CuentasOrden.IVA,
            AsientoContable.TasaIVA = CuentasOrden.TasaIVA,
            AsientoContable.TasaRetencionIVA = CuentasOrden.TasaRetencionIVA,
            AsientoContable.TasaRetencionISR = CuentasOrden.TasaRetencionISR
        FROM #tmpAsientosContableD AsientoContable
        INNER JOIN dbo.vCNTasientosDpolizas AsientoD ON AsientoD.IdAsientoD = AsientoContable.idAsientoD
        INNER JOIN dbo.vCNToperacionesCuentasOrden CuentasOrden ON CuentasOrden.IdOperacionCuentasOrden = AsientoContable.IdTransaccion
        WHERE AsientoContable.Tipo = 6 AND AsientoContable.EsValida = 1;
    END;

    -------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------
    IF EXISTS (SELECT TOP (1) Tipo FROM #tmpAsientosContableD)
    BEGIN
        --se busca la estructura contable
        UPDATE AsientoContable
        SET IdEstructuraContableD = EstructurasContable.IdEstructuraContableD,
            IdCuentaContable = EstructurasContable.IdCuentaContable,
            IdCuentaContableComplementaria = EstructurasContable.IdCuentaContableComplementaria,
            IdCentroCostos = IIF(EstructurasContable.EsBalance = 1, EstructurasContable.IdCentroCostos, AsientoContable.IdCentroCostos),
            Cargo = IIF(AsientoContable.EsCargo = 1, ABS (AsientoContable.valor), 0),
            Abono = IIF(AsientoContable.EsCargo = 0, ABS (AsientoContable.valor), 0)
        FROM #tmpAsientosContableD AsientoContable
        LEFT JOIN dbo.vCNTestructurasContablesDpolizas EstructurasContable ON EstructurasContable.IdEstructuraContableE = AsientoContable.IdEstructuraContableE
        WHERE EstructurasContable.IdTipoDRubro = AsientoContable.IdTipoDRubro AND ((EstructurasContable.TipoDivisaDivision = 0 AND EstructurasContable.IdTipoDimpuesto = AsientoContable.IdTipoDImpuesto) OR (EstructurasContable.TipoDivisaDivision = 2 AND EstructurasContable.IdDivisa = AsientoContable.IdDivisa) OR (EstructurasContable.TipoDivisaDivision = 1 AND EstructurasContable.IdDivision = AsientoContable.IdDivision) OR (EstructurasContable.TipoDivisaDivision = 3 AND EstructurasContable.IdDivisa = AsientoContable.IdDivisa AND EstructurasContable.IdAuxiliar = AsientoContable.IdAuxiliar) OR (EstructurasContable.TipoDivisaDivision = 4 AND EstructurasContable.IdDivision = AsientoContable.IdDivision AND EstructurasContable.IdBienServicio = AsientoContable.IdBienServicio));
    END;

    INSERT INTO #tmpAsientosOperaciones (IdOperacion, IdEjercicio, IdPeriodo, IdListaDpoliza, IdSucursalPrincipal, Cargos, Abonos)
    SELECT AsientoContable.IdOperacion,
           Periodo.IdEjercicio,
           AsientoContable.IdPeriodo,
           AsientoContable.IdListaDpoliza,
           (SELECT TOP (1) IdSucursal
            FROM #tmpAsientosContableD AsientoContable
            WHERE AsientoContable.EsValida = 1 AND Tipo <> 3 AND AsientoContable.IdOperacion = AsientoContable.IdOperacion
            ORDER BY AsientoContable.Tipo,
                     AsientoContable.IdTransaccion) AS IdSucursalPrincipal,
           Cargos = SUM (AsientoContable.Cargo),
           Abonos = SUM (AsientoContable.Abono)
    FROM #tmpAsientosContableD AsientoContable
    INNER JOIN dbo.tCTLperiodos Periodo ON Periodo.IdPeriodo = AsientoContable.IdPeriodo
    GROUP BY AsientoContable.IdOperacion,
             Periodo.IdEjercicio,
             AsientoContable.IdPeriodo,
             AsientoContable.IdListaDpoliza;

    -- Ordenamiento
    UPDATE AsientoContable
    SET Partida = tmp.Partida
    FROM #tmpAsientosContableD AsientoContable
    INNER JOIN (SELECT AsientosContable.Id,
                       Partida = ROW_NUMBER () OVER (PARTITION BY AsientosContable.IdPeriodo, AsientosContable.IdListaDpoliza ORDER BY Cuenta.Codigo)
                FROM #tmpAsientosContableD AsientosContable
                INNER JOIN dbo.tCNTcuentas Cuenta ON Cuenta.IdCuentaContable = AsientosContable.IdCuentaContable
                WHERE AsientosContable.EsValida = 1) AS tmp ON tmp.Id = AsientoContable.Id;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional (Tipo, IdTransaccionPoliza, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdCliente, IdClienteFiscal, IdEmisorProveedor, IdProveedorFiscal, IdBienServicio, IdCuentaABCD, IdDivisa, IdOperacion, IdTransaccion, IdSucursal, Concepto, Referencia, IdSaldoDestino, IdOperacionTransaccion)
        SELECT DISTINCT AsientoContable.Tipo,
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
        INNER JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.IdTransaccion = Transaccion.IdTransaccion
        WHERE AsientoContable.Tipo = 1 AND AsientoContable.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional (Tipo, IdTransaccionPoliza, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdSocio, IdBienServicio, IdDivision, IdDivisa, IdOperacion, IdTransaccionFinanciera, IdSucursal, Concepto, Referencia, IdSaldoDestino, IdOperacionTransaccion)
        SELECT DISTINCT AsientoContable.Tipo,
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
        INNER JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.IdTransaccion = TransaccionFinanciera.IdTransaccion
        WHERE AsientoContable.Tipo = 2 AND AsientoContable.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional (Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdOperacionDOrigen, IdSucursal, Concepto, Referencia, IdOperacionTransaccion)
        SELECT DISTINCT AsientoContable.Tipo,
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
                        OperacionD.IdOperacionTransaccion
        FROM dbo.vCNToperacionesD OperacionD
        INNER JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.IdTransaccion = OperacionD.IdOperacionD
        WHERE AsientoContable.Tipo = 3 AND AsientoContable.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional (Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdTransaccion, IdSucursal, Concepto, Referencia, IdOperacionTransaccion, IdPersona, IdTransaccionImpuesto)
        SELECT DISTINCT AsientoContable.Tipo,
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
        INNER JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.IdTransaccion = TransaccionImpuesto.IdTransaccionImpuesto
        WHERE AsientoContable.Tipo = 4 AND AsientoContable.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional (Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdSucursal, Concepto, Referencia, IdPersona, IdOperacionTransaccion, IdOperacionCuentasOrden, IdOperacionDOrigen)
        SELECT DISTINCT AsientoContable.Tipo,
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
                        CuentaOrden.IdOperacionCuentasOrden,
                        CuentaOrden.IdOperacionD
        FROM dbo.vCNToperacionesCuentasOrden CuentaOrden
        INNER JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.IdTransaccion = CuentaOrden.IdOperacionCuentasOrden
        WHERE AsientoContable.Tipo = 6 AND AsientoContable.EsValida = 1;
    END;

    --Sí se muestra la póliza en la modalidad de desarrollo, donde se muestran los ID's no se guardará la póliza
    IF (@MostrarPoliza = 1 AND @MostrarInformacionUsuario = 0)
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
        RIGHT JOIN (SELECT AsientoContable.Id,
                           AsientoContable.Partida,
                           AsientoContable.IdCuentaContable,
                           AsientoContable.IdCentroCostos,
                           AsientoContable.Cargo,
                           AsientoContable.Abono,
                           AsientoContable.IdEstructuraContableD,
                           AsientoContable.Tipo,
                           AsientoContable.IdTransaccion,
                           AsientoContable.idAsientoD,
                           AsientoContable.IdPeriodo,
                           AsientoContable.IdListaDpoliza,
                           AsientoContable.EsIntersucursal,
                           AsientoContable.IdSucursal,
                           AsientoContable.EsValida,
                           AsientoD.Campo,
                           rubro = Rubro.Descripcion,
                           cuenta = Cuenta.Codigo,
                           nombreCuenta = Cuenta.Descripcion
                    FROM #tmpAsientosContableD AsientoContable
                    INNER JOIN dbo.tCNTasientosD AsientoD WITH (NOLOCK) ON AsientoD.IdAsientoD = AsientoContable.idAsientoD
                    INNER JOIN dbo.tCNTcuentas Cuenta WITH (NOLOCK) ON Cuenta.IdCuentaContable = AsientoContable.IdCuentaContable
                    INNER JOIN dbo.tCTLtiposD Rubro WITH (NOLOCK) ON Rubro.IdTipoD = AsientoD.IdTipoDRubro) AS tmp ON tmp.Tipo = AsientoContableAdicional.Tipo AND tmp.IdTransaccion = AsientoContableAdicional.IdTransaccionPoliza
        ORDER BY tmp.IdPeriodo,
                 tmp.IdListaDpoliza,
                 tmp.Partida;

        IF @IdCierre <> 0
        BEGIN
            SELECT t.IdOperacion,
                   Cargo = SUM (tmp.Cargo),
                   Abono = SUM (tmp.Abono)
            FROM #tmpAsientosContableDatosAdicional t
            RIGHT JOIN (SELECT AsientoContable.Id,
                               AsientoContable.Partida,
                               AsientoContable.Tipo,
                               AsientoContable.IdTransaccion,
                               AsientoContable.idAsientoD,
                               AsientoContable.IdCuentaContable,
                               AsientoContable.Cargo,
                               AsientoContable.Abono
                        FROM #tmpAsientosContableD AsientoContable
                        INNER JOIN dbo.tCNTasientosD AsientoD WITH (NOLOCK) ON AsientoD.IdAsientoD = AsientoContable.idAsientoD
                        INNER JOIN dbo.tCNTcuentas Cuenta WITH (NOLOCK) ON Cuenta.IdCuentaContable = AsientoContable.IdCuentaContable
                        INNER JOIN dbo.tCTLtiposD Rubro WITH (NOLOCK) ON Rubro.IdTipoD = AsientoD.IdTipoDRubro) AS tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
            WHERE tmp.Partida <> 0
            GROUP BY t.IdOperacion
            HAVING (SUM (tmp.Cargo) - SUM (tmp.Abono)) <> 0;
        END;

        DECLARE @IdTipoOperacion INT;

        IF (@TipoFiltro = 1)
            SELECT @IdTipoOperacion = IdTipoOperacion
            FROM dbo.tGRLoperaciones WITH (NOLOCK)
            WHERE IdOperacion = @IdOperacion;

        IF (@IdTipoOperacion = 4 OR @IdTipoOperacion = 503)
        BEGIN
            SELECT 'CTA',
                   AsientosContable.IdPeriodo,
                   AsientosContable.IdListaDpoliza,
                   IdOperacion = IIF(AsientosContable.EsIntersucursal = 1, AsientosContable.IdOperacion, AsientosContableAdicional.IdOperacion),
                   AsientosContableAdicional.IdCuenta,
                   Cargos = SUM (AsientosContable.Cargo),
                   Abonos = SUM (AsientosContable.Abono)
            FROM #tmpAsientosContableDatosAdicional AsientosContableAdicional
            RIGHT JOIN #tmpAsientosContableD AsientosContable ON AsientosContable.Tipo = AsientosContableAdicional.Tipo AND AsientosContable.IdTransaccion = AsientosContableAdicional.IdTransaccionPoliza
            WHERE AsientosContable.EsValida = 1
            GROUP BY AsientosContable.IdPeriodo,
                     AsientosContable.IdListaDpoliza,
                     IIF(AsientosContable.EsIntersucursal = 1, AsientosContable.IdOperacion, AsientosContableAdicional.IdOperacion),
                     AsientosContableAdicional.IdCuenta
            HAVING SUM (AsientosContable.Cargo) <> SUM (AsientosContable.Abono);

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
    IF (@MostrarPoliza = 1 AND @MostrarInformacionUsuario = 1)
    BEGIN
        SELECT tmp.Partida,
               Cuenta = tmp.cuenta,
               [Nombre cuenta] = tmp.nombreCuenta,
               tmp.Cargo,
               tmp.Abono,
               tmp.Campo,
               tmp.rubro,
               [Tipo de saldo] = Auxiliar.Descripcion,
               [Bien Servicio] = BienServicio.Descripcion,
               [Código E. Contable] = EstructuraContable.Codigo,
               [Estructura contable] = EstructuraContable.Descripcion,
               [División] = Division.Descripcion,
               [Sucursal] = Sucursal.Descripcion,
               AsientosContableAdicional.Referencia,
               AsientosContableAdicional.IdPersona
        FROM #tmpAsientosContableDatosAdicional AsientosContableAdicional
        LEFT JOIN dbo.tCNTauxiliares Auxiliar ON Auxiliar.IdAuxiliar = AsientosContableAdicional.IdAuxiliar
        LEFT JOIN dbo.tCNTdivisiones Division ON Division.IdDivision = AsientosContableAdicional.IdDivision
        LEFT JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal = AsientosContableAdicional.IdSucursal
        LEFT JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON AsientosContableAdicional.IdBienServicio = BienServicio.IdBienServicio
        RIGHT JOIN (SELECT AsientoContable.*,
                           AsientoD.Campo,
                           Rubro.Descripcion AS rubro,
                           Cuenta.Codigo AS cuenta,
                           Cuenta.Descripcion AS nombreCuenta
                    FROM #tmpAsientosContableD AsientoContable
                    INNER JOIN dbo.tCNTasientosD AsientoD WITH (NOLOCK) ON AsientoD.IdAsientoD = AsientoContable.idAsientoD
                    INNER JOIN dbo.tCNTcuentas Cuenta WITH (NOLOCK) ON Cuenta.IdCuentaContable = AsientoContable.IdCuentaContable
                    INNER JOIN dbo.tCTLtiposD Rubro WITH (NOLOCK) ON Rubro.IdTipoD = AsientoD.IdTipoDRubro) AS tmp ON tmp.Tipo = AsientosContableAdicional.Tipo AND tmp.IdTransaccion = AsientosContableAdicional.IdTransaccionPoliza
        LEFT JOIN dbo.tCNTestructurasContablesE EstructuraContable ON EstructuraContable.IdEstructuraContableE = tmp.IdEstructuraContableE
        WHERE tmp.Partida IS NOT NULL
        ORDER BY tmp.IdPeriodo,
                 tmp.IdListaDpoliza,
                 tmp.Partida;

        IF (@TipoFiltro = 1)
            SELECT @IdTipoOperacion = IdTipoOperacion
            FROM dbo.tGRLoperaciones WITH (NOLOCK)
            WHERE IdOperacion = @IdOperacion;

        IF (@IdTipoOperacion = 4 OR @IdTipoOperacion = 503)
        BEGIN
            SELECT 'CTA',
                   AsientoContable.IdPeriodo,
                   AsientoContable.IdListaDpoliza,
                   IdOperacion = IIF(AsientoContable.EsIntersucursal = 1, AsientoContable.IdOperacion, AsientosContableAdicional.IdOperacion),
                   AsientosContableAdicional.IdCuenta,
                   Cargos = SUM (AsientoContable.Cargo),
                   Abonos = SUM (AsientoContable.Abono)
            FROM #tmpAsientosContableDatosAdicional AsientosContableAdicional
            RIGHT JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.Tipo = AsientosContableAdicional.Tipo AND AsientoContable.IdTransaccion = AsientosContableAdicional.IdTransaccionPoliza
            WHERE AsientoContable.EsValida = 1
            GROUP BY AsientoContable.IdPeriodo,
                     AsientoContable.IdListaDpoliza,
                     IIF(AsientoContable.EsIntersucursal = 1, AsientoContable.IdOperacion, AsientosContableAdicional.IdOperacion),
                     AsientosContableAdicional.IdCuenta
            HAVING SUM (AsientoContable.Cargo) <> SUM (AsientoContable.Abono);

            SELECT AsientosContableAdicional.*,
                   AsientoContable.*,
                   AsientoD.Campo
            FROM #tmpAsientosContableDatosAdicional AsientosContableAdicional
            RIGHT JOIN #tmpAsientosContableD AsientoContable ON AsientoContable.Tipo = AsientosContableAdicional.Tipo AND AsientoContable.IdTransaccion = AsientosContableAdicional.IdTransaccionPoliza
            INNER JOIN dbo.tCNTasientosD AsientoD ON AsientoD.IdAsientoD = AsientoContable.idAsientoD
            WHERE AsientoContable.EsValida = 1;
        END;

        RETURN -1;
    END;

    PRINT 'ESTATUS';

    UPDATE AsientoContable
    SET IdEstatus = x.IdEstatus
    FROM #tmpAsientosContableE AsientoContable
    JOIN (SELECT IdPeriodo,
                 IdListaDpoliza,
                 Partidas = COUNT (*),
                 Cargos = SUM (AsientoContable.Cargo),
                 Abonos = SUM (AsientoContable.Abono),
                 IdEstatus = IIF(SUM (AsientoContable.Cargo) = SUM (AsientoContable.Abono), 1, 13)
          FROM #tmpAsientosContableD AsientoContable
          WHERE EsValida = 1
          GROUP BY IdPeriodo,
                   IdListaDpoliza)AS x ON x.IdPeriodo = AsientoContable.IdPeriodo AND x.IdListaDpoliza = AsientoContable.IdListaDpoliza;

    DECLARE @numeroPartidasValidas AS INT = (SELECT COUNT (*) FROM #tmpAsientosContableE WHERE Idestatus = 1);

    IF (@numeroPartidasValidas = 0)
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
               Cargos = SUM (AsientoContable.Cargo),
               Abonos = SUM (AsientoContable.Abono),
               IdEstatus = IIF(SUM (AsientoContable.Cargo) = SUM (AsientoContable.Abono), 1, 13)
        FROM #tmpAsientosContableD AsientoContable
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
        DECLARE @fecha          DATE,
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
            IF (@Recontabilizacion = 1)
            BEGIN
                IF (@TipoFiltro = 1 AND @IdOperacion <> 0)
                BEGIN
                    IF EXISTS (SELECT 1
                               FROM dbo.tCNTpolizasFoliosOperaciones wt
                               WHERE @TipoFiltro = 1 AND IdOperacion = @IdOperacion AND @IdOperacion <> 0 AND IdListaDPoliza = @IdListaDpoliza AND @IdPolizaE <> 0)
                    BEGIN
                        PRINT 'SE ULTIZA EL FOLIO ORIGINAL';

                        UPDATE PolizaE
                        SET Folio = tmp.Folio
                        FROM dbo.tCNTpolizasE PolizaE
                        JOIN (SELECT IdPolizaE = @IdPolizaE,
                                     Folio,
                                     Numero = ROW_NUMBER () OVER (ORDER BY Principal DESC)
                              FROM dbo.tCNTpolizasFoliosOperaciones
                              WHERE IdOperacion = @IdOperacion AND IdListaDPoliza = @IdListaDpoliza) tmp ON tmp.IdPolizaE = PolizaE.IdPolizaE AND tmp.Numero = 1;
                    END;
                END;
                ELSE
                BEGIN
                    IF (@TipoFiltro = 2 AND @IdCierre <> 0)
                    BEGIN
                        IF EXISTS (SELECT 1
                                   FROM dbo.tCNTpolizasFoliosOperaciones
                                   WHERE @TipoFiltro = 2 AND IdCierre = @IdCierre AND @IdCierre <> 0 AND IdListaDPoliza = @IdListaDpoliza AND @IdPolizaE <> 0)
                        BEGIN
                            PRINT 'SE ULTIZA EL FOLIO ORIGINAL';

                            UPDATE PolizaE
                            SET Folio = tmp.Folio
                            FROM dbo.tCNTpolizasE PolizaE
                            JOIN (SELECT IdPolizaE = @IdPolizaE,
                                         Folio,
                                         Numero = ROW_NUMBER () OVER (ORDER BY Principal DESC)
                                  FROM dbo.tCNTpolizasFoliosOperaciones
                                  WHERE IdCierre = @IdCierre AND IdListaDPoliza = @IdListaDpoliza) tmp ON tmp.IdPolizaE = PolizaE.IdPolizaE AND tmp.Numero = 1;
                        END;
                    END;
                END;
            END;

            PRINT @IdPolizaE;

            IF (NOT @IdPolizaE IS NULL)
            BEGIN
                /*Agregamos los detalles por periodo - tipo de póliza*/
                INSERT dbo.tCNTpolizasD (IdPolizaE, Partida, IdCuentaContable, IdCentroCostos, Cargo, Abono, BaseIVA, IVA, TasaIVA, TasaRetencionIVA, TasaRetencionISR, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdSocio, IdCliente, IdClienteFiscal, IdEmisorProveedor, IdProveedorFiscal, IdBienServicio, IdAlmacen, IdDivision, IdCuentaABCD, IdDivisa, IdEstructuraContableD, IdOperacion, IdOperacionDOrigen, IdTransaccion, IdTransaccionFinanciera, IdSucursal, IdAsientoD, IdSaldoDestino, Concepto, Referencia, IdImpuesto, IdTransaccionImpuesto, IdOperacionCuentasOrden)
                SELECT @IdPolizaE,
                       Partida = ROW_NUMBER () OVER (ORDER BY AsientoContable.IdPeriodo, AsientoContable.IdListaDpoliza, AsientoContable.Partida),
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
                WHERE AsientoContable.EsValida = 1 AND AsientoContable.IdPeriodo = @IdPeriodo AND AsientoContable.IdListaDpoliza = @IdListaDpoliza;

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
                INNER JOIN #tmpAsientosOperaciones AsientoOperacion ON AsientoOperacion.IdOperacion = Operacion.IdOperacion
                WHERE Operacion.IdOperacion > 0 AND AsientoOperacion.IdPeriodo = @IdPeriodo AND AsientoOperacion.IdListaDpoliza = @IdListaDpoliza AND AsientoOperacion.IdOperacion <> 0;

                --operaciones faltantes hijas
                UPDATE Operacion
                SET TienePoliza = 1,
                    IdPolizaE = @IdPolizaE
                FROM dbo.tGRLoperaciones Operacion WITH (NOLOCK)
                INNER JOIN #tmpAsientosOperaciones AsientoOperacion ON AsientoOperacion.IdOperacion = Operacion.IdOperacionPadre
                WHERE Operacion.IdOperacion > 0 AND AsientoOperacion.IdPeriodo = @IdPeriodo AND AsientoOperacion.IdListaDpoliza = @IdListaDpoliza AND AsientoOperacion.IdOperacion <> 0 AND Operacion.IdPolizaE = 0;
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

        /*INICIO VALIDACIONES*/
        IF (@UsaMovimientoIntersucursal = 1)
        BEGIN
            IF EXISTS (SELECT Poliza.IdPeriodo,
                              Poliza.IdListaDpoliza,
                              PolizaD.IdSucursal,
                              Cargo = SUM (PolizaD.Cargo),
                              Abono = SUM (PolizaD.Abono)
                       FROM dbo.tCNTpolizasE Poliza WITH (NOLOCK)
                       INNER JOIN dbo.tCNTpolizasD PolizaD WITH (NOLOCK) ON PolizaD.IdPolizaE = Poliza.IdPolizaE
                       WHERE Poliza.IdPolizaE = @IdPolizaE
                       GROUP BY Poliza.IdPeriodo,
                                Poliza.IdListaDpoliza,
                                PolizaD.IdSucursal
                       HAVING SUM (PolizaD.Cargo) <> SUM (PolizaD.Abono))
            BEGIN
                SET @IdEstatusPoliza = 34;

                SELECT Poliza.IdPeriodo,
                       Poliza.IdListaDpoliza,
                       PolizaD.IdSucursal,
                       Cargo = SUM (PolizaD.Cargo),
                       Abono = SUM (PolizaD.Abono)
                FROM dbo.tCNTpolizasE Poliza WITH (NOLOCK)
                INNER JOIN dbo.tCNTpolizasD PolizaD WITH (NOLOCK) ON PolizaD.IdPolizaE = Poliza.IdPolizaE
                WHERE Poliza.IdPolizaE = @IdPolizaE
                GROUP BY Poliza.IdPeriodo,
                         Poliza.IdListaDpoliza,
                         PolizaD.IdSucursal
                HAVING SUM (PolizaD.Cargo) <> SUM (PolizaD.Abono);

                RAISERROR ('Cuadre por sucursal', 16, 8);

                RETURN -1;
            END;
        END;

        IF EXISTS (SELECT IdSucursal FROM dbo.tCNTpolizasD WITH (NOLOCK) WHERE IdPolizaE = @IdPolizaE AND IdSucursal = 0)
        BEGIN
            SET @Mensaje = CONCAT ('Registros con sucursal cero ID(', @IdOperacion, ')');

            SELECT IdSucursal
            FROM dbo.tCNTpolizasD WITH (NOLOCK)
            WHERE IdPolizaE = @IdPolizaE AND IdSucursal = 0;

            SET @IdEstatusPoliza = 34;

            RAISERROR (@Mensaje, 16, 8);
        END;

        IF EXISTS (SELECT IdCuentaContable
                   FROM dbo.tCNTpolizasD WITH (NOLOCK)
                   WHERE IdPolizaE = @IdPolizaE AND IdCuentaContable = 0)
        BEGIN
            SET @Mensaje = CONCAT ('Registros sin cuenta contable ID(', @IdOperacion, ')');

            RAISERROR (@Mensaje, 16, 8);

            SET @IdEstatusPoliza = 34;

            SELECT *
            FROM dbo.tCNTpolizasD WITH (NOLOCK)
            WHERE IdPolizaE = @IdPolizaE AND IdCuentaContable = 0;

            RAISERROR (@Mensaje, 16, 8);
        END;

        /*FIN*/
        SET @IdEstatusPoliza = 1;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    END TRY
    BEGIN CATCH
        DECLARE @idtipox AS INT = (SELECT TOP (1) Operacion.IdTipoOperacion
                                   FROM dbo.tGRLoperaciones Operacion WITH (NOLOCK)
                                   WHERE Operacion.IdOperacion = @IdOperacion AND @IdCierre = 0
                                   ORDER BY Operacion.IdOperacion);

        IF (@idtipox = 25)
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