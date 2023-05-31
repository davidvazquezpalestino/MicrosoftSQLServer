
/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.procedures WHERE object_id = OBJECT_ID ('pCTLtiposBase'))
    DROP PROCEDURE pCTLtiposBase;
GO


CREATE PROCEDURE dbo.pCTLtiposBase
@TipoOperacion VARCHAR(20),
@Filtro VARCHAR(500)
AS
BEGIN
    DECLARE @cadena AS VARCHAR(MAX) = '';

    -- para los listados de tipo SAT agregamos uno donde se concatena la descripción
    IF @TipoOperacion = 'SAT'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(Descripcion), IdTipoE, Tipo
			FROM (	SELECT IdTipoD,Descripcion = CONCAT(Codigo, '' - '', Descripcion),IdTipoE,Tipo = 0
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 and  IdTipoE  IN (', @Filtro, ') ) AS tipos			
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    IF @TipoOperacion = 'LST'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(Descripcion), IdTipoE, Tipo
			FROM (	SELECT IdTipoD,Descripcion,IdTipoE=-695,Tipo = 0
					FROM dbo.tCTLtiposD
					WHERE IdEstatus=1 and IdTipoD IN (143,144,398,716,1570,2196,2197) AND -695 IN (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD,Descripcion,IdTipoE,Tipo = 0
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 and  IdTipoE  IN (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD = IdListaD,Descripcion,IdTipoE,Tipo = 1
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND IdTipoE  in (', @Filtro, ') ) AS tipos
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    IF @TipoOperacion = 'LSTpld'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(Descripcion), IdTipoE, Tipo
			FROM (	SELECT IdTipoD,Descripcion,IdTipoE=-695,Tipo = 0
					FROM dbo.tCTLtiposD
					WHERE IdEstatus=1 and IdTipoD IN (143,144,398,716,1570,2196,2197) AND -695 IN (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD,Descripcion,IdTipoE,Tipo = 0
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 and  IdTipoE  IN (', @Filtro, ') and idtipod Not in (2642)
					UNION ALL
					SELECT IdTipoD = IdListaD,Descripcion,IdTipoE,Tipo = 1
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND IdTipoE  in (', @Filtro, ') ) AS tipos
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    IF @TipoOperacion = 'LSTtipoD'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(Descripcion),DescripcionLarga = UPPER(Descripcion),RangoInicio,RangoFin,IdListaDpadre, IdTipoE,IdTipoDpadre, valor
			FROM (	SELECT IdTipoD,Descripcion,DescripcionLarga,RangoInicio,RangoFin,IdTipoE=-695,IdListaDpadre = 0,IdTipoDPadre,Valor = 0
					FROM dbo.tCTLtiposD
					WHERE IdEstatus=1 and IdTipoD IN (143,144,398,716,1570,2196,2197) AND -695 IN (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD,Descripcion,DescripcionLarga,RangoInicio,RangoFin,IdTipoE=-695,IdListaDpadre = 0,IdTipoDPadre,Valor = 0
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 AND IdTipoDpadre  IN (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD = IdListaD,Descripcion,DescripcionLarga,RangoInicio,RangoFin,IdTipoE=-695,IdListaDpadre = 0,IdTipoDPadre,Valor = 0
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND IdTipoDpadre  IN (', @Filtro, ') ) AS tipos
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    IF @TipoOperacion = 'DESC'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(Descripcion), DescripcionLarga = UPPER(DescripcionLarga) ,IdTipoE, Tipo
			FROM (	SELECT IdTipoD,Codigo,Descripcion,DescripcionLarga,IdTipoE,Tipo = 0
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 and  IdTipoE  IN (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD = IdListaD,Codigo,Descripcion,DescripcionLarga,IdTipoE,Tipo = 1
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND IdTipoE  IN (', @Filtro, ') ) AS tipos
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    IF @TipoOperacion = 'VAL'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(Descripcion), DescripcionLarga = UPPER(DescripcionLarga), IdTipoE, IdTipoDpadre, Valor, RangoInicio, Tipo,IdListaDPadre,RangoFin
			FROM (	SELECT IdTipoD, Codigo, Descripcion, DescripcionLarga, IdTipoE, IdTipoDpadre, Valor, RangoInicio, Tipo = 0,0 as IdListaDpadre,RangoFin
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 and IdTipoE  in (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD = IdListaD,Codigo,Descripcion,DescripcionLarga,IdTipoE,IdTipoDpadre,Valor,cast(RangoInicio as int),Tipo = 1,IdListaDpadre,RangoFin
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND IdTipoE  in (', @Filtro, ') ) AS tipos
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    IF @TipoOperacion = 'VALDESLAR'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(DescripcionLarga), DescripcionLarga = UPPER(Descripcion), IdTipoE, IdTipoDpadre, Valor, RangoInicio, Tipo,IdListaDPadre,RangoFin
			FROM (	SELECT IdTipoD, Codigo, Descripcion, DescripcionLarga, IdTipoE, IdTipoDpadre, Valor, RangoInicio, Tipo = 0,0 as IdListaDpadre,RangoFin
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 and IdTipoE  in (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD = IdListaD,Codigo,Descripcion,DescripcionLarga,IdTipoE,IdTipoDpadre,Valor,cast(RangoInicio as int),Tipo = 1,IdListaDpadre,RangoFin
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND IdTipoE  in (', @Filtro, ') ) AS tipos
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    IF @TipoOperacion = 'COBRANZA'
    BEGIN
        SET @cadena = CONCAT ('SELECT IdTipoD, Descripcion = UPPER(Descripcion), IdTipoE, Tipo
			FROM (	SELECT IdTipoD,Descripcion,IdTipoE,Tipo = 0
					FROM dbo.tCTLtiposD WITH (NOLOCK)
					WHERE IdEstatus=1 AND IdTipoD IN(2661) and  IdTipoE  IN (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD = IdListaD,Descripcion,IdTipoE,Tipo = 1
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND l.IdListaD IN(-1397) AND IdTipoE  in (', @Filtro, ')
					UNION ALL
					SELECT IdTipoD = IdListaD,Descripcion,IdTipoE,Tipo = 1
					FROM dbo.tCATlistasD l WITH (NOLOCK)
					JOIN dbo.tCTLestatusActual e WITH (NOLOCK) ON e.IdEstatusActual = l.IdEstatusActual
					WHERE e.IdEstatus = 1 AND IdTipoE  in (395)
					) AS tipos
			ORDER BY IdTipoE, Descripcion');

        EXEC ( @cadena );

        RETURN;
    END;

    /*IMPLEMENTAR EN COMBOBOX FILTRA POR TIPOS E*/
    IF @TipoOperacion = 'IDENTITY'
    BEGIN
        SELECT Detalle.IdTipoD,
               Detalle.IdTipoE,
               Detalle.Codigo,
               Detalle.Descripcion,
               Detalle.IdTipoDPadre
        FROM ( SELECT Encabezado.IdTipoE
               FROM dbo.tCTLtiposE Encabezado WITH ( NOLOCK )
               INNER JOIN dbo.fSplitString (@Filtro, ',') x ON x.splitdata = Encabezado.IdTipoE ) AS Tipo
        INNER JOIN dbo.tCTLtiposD Detalle ON Detalle.IdTipoE = Tipo.IdTipoE AND Detalle.IdEstatus = 1
        ORDER BY Detalle.Descripcion;
    END;

    /*IMPLEMENTAR EN COMBOBOX FILTRA TIPOSD PADRE */
    IF @TipoOperacion = 'IDENTITYIdTipoDPadre'
    BEGIN
        SELECT Detalle.IdTipoD,
               Detalle.IdTipoE,
               Detalle.Codigo,
               Detalle.Descripcion,
               Detalle.IdTipoDPadre
        FROM ( SELECT Encabezado.IdTipoD
               FROM dbo.tCTLtiposD Encabezado WITH ( NOLOCK )
               INNER JOIN dbo.fSplitString (@Filtro, ',') x ON x.splitdata = Encabezado.IdTipoD ) AS Tipo
        INNER JOIN dbo.tCTLtiposD Detalle ON Detalle.IdTipoDPadre = Tipo.IdTipoD
        ORDER BY Detalle.Descripcion;
    END;

    /*IMPLEMENTAR EN COMBOBOX FILTRA TIPOSD */
    IF @TipoOperacion = 'IDENTITYIdTipoD'
    BEGIN
        SELECT Detalle.IdTipoD,
               Detalle.IdTipoE,
               Detalle.Codigo,
               Detalle.Descripcion,
               Detalle.IdTipoDPadre
        FROM dbo.tCTLtiposD Detalle WITH ( NOLOCK )
        INNER JOIN dbo.fSplitString (@Filtro, ',') x ON x.splitdata = Detalle.IdTipoD
        ORDER BY Detalle.Descripcion;
    END;

    IF @TipoOperacion = 'LISTAD'
    BEGIN
        SELECT Detalle.IdListaD,
               Detalle.IdTipoE,
               Detalle.Codigo,
               Detalle.Descripcion,
               Detalle.IdTipoDpadre,
               Detalle.IdListaDPadre
        FROM ( SELECT Encabezado.IdTipoE
               FROM dbo.tCTLtiposE Encabezado WITH ( NOLOCK )
               INNER JOIN dbo.fSplitString (@Filtro, ',') x ON x.splitdata = Encabezado.IdTipoE ) AS Tipo
        INNER JOIN dbo.tCATlistasD Detalle ON Detalle.IdTipoE = Tipo.IdTipoE
        INNER JOIN dbo.tCTLestatusActual Estatus ON Estatus.IdEstatusActual = Detalle.IdEstatusActual
        WHERE Estatus.IdEstatus = 1
        ORDER BY Detalle.Descripcion;
    END;
END;
GO


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/

IF EXISTS ( SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vGRLauxiliarCuentaABCDsaldos'))
    DROP VIEW dbo.vGRLauxiliarCuentaABCDsaldos;
GO


CREATE VIEW [dbo].[vGRLauxiliarCuentaABCDsaldos]
AS
SELECT Resumen.IdSaldo,
       Resumen.SaldoDescripcion,
       Resumen.SaldoFecha,
       Resumen.SaldoVencimiento,
       Transaccion.TotalAbonos AS Retiro,
       Transaccion.TotalCargos AS Deposito,
       Resumen.IdAuxiliar,
       Operacion.Concepto,
       Resumen.IdCuentaABCD,
       Transaccion.Fecha AS TransaccionFecha
FROM dbo.vSDOresumenCuentaABCD Resumen
INNER JOIN dbo.tSDOtransacciones Transaccion WITH ( NOLOCK ) ON Transaccion.IdSaldoDestino = Resumen.IdSaldo
INNER JOIN dbo.tGRLoperaciones Operacion WITH ( NOLOCK ) ON Operacion.IdOperacion = Resumen.SaldoIdOperacion
WHERE Transaccion.IdEstatus <> 18;
GO


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/

IF EXISTS ( SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vSDOresumenCuentaABCD'))
    DROP VIEW dbo.vSDOresumenCuentaABCD;
GO


CREATE VIEW [dbo].[vSDOresumenCuentaABCD]
AS
SELECT Dominio.Descripcion,
       NIVEL1 = CASE Estatus.IdTipoDDominio WHEN 700 THEN 'Deudores/Acreedores'
                                            WHEN 851 THEN 'Cajas'
                                            WHEN 852 THEN 'Cajas'
                                            WHEN 145 THEN 'Bancos'
                                            ELSE NULL
                END,
       NIVEL2 = CASE Estatus.IdTipoDDominio WHEN 700 THEN Persona.Nombre
                                            WHEN 851 THEN Sucursal.Descripcion
                                            WHEN 852 THEN Sucursal.Descripcion
                                            WHEN 145 THEN Divisa.Codigo
                                            ELSE NULL
                END,
       NIVEL3 = CASE Estatus.IdTipoDDominio WHEN 700 THEN Divisa.Codigo
                                            WHEN 851 THEN Divisa.Codigo
                                            WHEN 852 THEN Divisa.Codigo
                                            WHEN 145 THEN Banco.NombreComercial
                                            ELSE NULL
                END,
       NIVEL4 = CASE Estatus.IdTipoDDominio WHEN 700 THEN CASE Saldo.Naturaleza WHEN 1 THEN 'Deudor'
                                                                                WHEN -1 THEN 'Acreedor'
                                                                                ELSE NULL
                                                          END
                                            WHEN 851 THEN Saldo.Descripcion
                                            WHEN 852 THEN Saldo.Descripcion
                                            WHEN 145 THEN Saldo.Descripcion
                                            ELSE NULL
                END,
       NIVEL5 = CASE Estatus.IdTipoDDominio WHEN 700 THEN Saldo.Descripcion + ' (' + Suc.Descripcion + ')'
                                            WHEN 851 THEN ''
                                            WHEN 852 THEN ''
                                            WHEN 145 THEN ''
                                            ELSE NULL
                END,
       Dominio.IdTipoD AS IdTipoDdominio,
       Cuenta.IdCuentaABCD,
       Cuenta.Codigo AS CuentaABCDcodigo,
       Cuenta.Descripcion AS CuentaABCDdescripcion,
       Saldo.IdSaldo,
       Saldo.Descripcion AS SaldoDescripcion,
       Saldo.Fecha AS SaldoFecha,
       Saldo.Vencimiento AS SaldoVencimiento,
       Saldo.IdOperacion AS SaldoIdOperacion,
       Estatus.IdEstatus AS IdEstatusCuentaABCD,
       Auxiliares.IdAuxiliar,
       Cuenta.IdSucursal
FROM dbo.tGRLcuentasABCD Cuenta WITH ( NOLOCK )
JOIN dbo.tSDOsaldos Saldo WITH ( NOLOCK ) ON Saldo.IdCuentaABCD = Cuenta.IdCuentaABCD
JOIN dbo.tFNZbancos Banco WITH ( NOLOCK ) ON Banco.IdBanco = Cuenta.IdBanco
JOIN dbo.tCTLestatusActual Estatus WITH ( NOLOCK ) ON Estatus.IdEstatusActual = Cuenta.IdEstatusActual
JOIN dbo.tCTLdivisas Divisa WITH ( NOLOCK ) ON Divisa.IdDivisa = Saldo.IdDivisa
JOIN dbo.tCTLtiposD Dominio WITH ( NOLOCK ) ON Estatus.IdTipoDDominio = Dominio.IdTipoD
JOIN dbo.tGRLpersonas Persona WITH ( NOLOCK ) ON Cuenta.IdPersona = Persona.IdPersona
JOIN dbo.tCTLsucursales Sucursal WITH ( NOLOCK ) ON Cuenta.IdSucursal = Sucursal.IdSucursal
JOIN dbo.tCTLsucursales Suc WITH ( NOLOCK ) ON Suc.IdSucursal = Saldo.IdSucursal
JOIN dbo.tCNTauxiliares Auxiliares WITH ( NOLOCK ) ON Auxiliares.IdAuxiliar = Saldo.IdAuxiliar
WHERE Cuenta.IdCuentaABCD <> 0 AND Saldo.IdEstatus <> 18;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vGRLauxiliarCuentaABCD'))
    DROP VIEW dbo.vGRLauxiliarCuentaABCD;
GO


CREATE VIEW [dbo].[vGRLauxiliarCuentaABCD]
AS
SELECT Operacion = CAST(( TipoOperacion.Codigo + '-' + Operacion.Serie + CAST(Operacion.Folio AS VARCHAR(10))) AS VARCHAR(50)),
       Transaccion.Fecha,
       Transaccion.Descripcion,
       Transaccion.Referencia,
       Cheque.Folio AS ChequeFolio,
       Transaccion.IdCheque,
       ReferenciaFolioCheque = IIF(Cheque.Folio = 0, Transaccion.Referencia, CAST(Cheque.Folio AS VARCHAR(15))),
       Retiro = Transaccion.TotalAbonos,
       Deposito = Transaccion.TotalCargos,
       TipoMovimiento = CASE WHEN Transaccion.TotalAbonos > 0 AND Transaccion.TotalCargos = 0 THEN 1 ---retiro
                             WHEN Transaccion.TotalAbonos = 0 AND Transaccion.TotalCargos > 0 THEN 2 ---Depósito
                             ELSE 0
                        END,
       Transaccion.SalvoBuenCobro,
       Transaccion.Concepto,
       Transaccion.SaldoAnterior,
       Transaccion.Saldo,
       Resumen.IdCuentaABCD,
       Resumen.CuentaABCDcodigo,
       Resumen.CuentaABCDdescripcion,
       TransaccionIdEstatus = Transaccion.IdEstatus,
       Transaccion.EstaConciliada,
       FechaConciliacion = Transaccion.FechaBanco,
       Transaccion.SaldoConciliado,
       Resumen.IdTipoDdominio,
       Resumen.IdSaldo,
       Transaccion.IdTransaccion,
       Resumen.SaldoVencimiento,
       Resumen.IdAuxiliar,
       Operacion.IdCorte
FROM dbo.vSDOresumenCuentaABCD Resumen
INNER JOIN dbo.tSDOtransacciones Transaccion WITH ( NOLOCK ) ON Transaccion.IdSaldoDestino = Resumen.IdSaldo
INNER JOIN dbo.tGRLoperaciones Operacion WITH ( NOLOCK ) ON Operacion.IdOperacion = Transaccion.IdOperacion
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH ( NOLOCK ) ON TipoOperacion.IdTipoOperacion = Operacion.IdTipoOperacion
INNER JOIN dbo.tFNZcheques Cheque WITH ( NOLOCK ) ON Cheque.IdCheque = Transaccion.IdCheque
WHERE Transaccion.IdEstatus <> 18;
GO


/*==========================================
    Por:  David Vázquez Palestino
  Fecha:  17/11/2020
  ==========================================*/
IF EXISTS ( SELECT object_id FROM sys.objects WHERE object_id = OBJECT_ID ('FnSDOultimoMovimientoCuentasABCD'))
    DROP FUNCTION FnSDOultimoMovimientoCuentasABCD;
GO


CREATE FUNCTION [dbo].[FnSDOultimoMovimientoCuentasABCD]
(
    @IdSaldo INT,
    @FechaInicio DATE
)
RETURNS TABLE
AS
RETURN ( SELECT IdTransaccion,
                Movimientos.Operacion,
                Movimientos.Fecha,
                Movimientos.Descripcion,
                Movimientos.Referencia,
                Movimientos.ChequeFolio,
                Movimientos.IdCheque,
                Movimientos.ReferenciaFolioCheque,
                Movimientos.Retiro,
                Movimientos.Deposito,
                Movimientos.TipoMovimiento,
                Movimientos.SalvoBuenCobro,
                Movimientos.Concepto,
                Movimientos.SaldoAnterior,
                Movimientos.Saldo,
                Movimientos.IdCuentaABCD,
                Movimientos.CuentaABCDcodigo,
                Movimientos.CuentaABCDdescripcion,
                Movimientos.TransaccionIdEstatus,
                Movimientos.EstaConciliada,
                Movimientos.FechaConciliacion,
                Movimientos.SaldoConciliado,
                Movimientos.idTipoDDominio,
                Movimientos.IdSaldo,
                Movimientos.SaldoVencimiento,
                Movimientos.IdAuxiliar,
                Movimientos.IdCorte
         FROM ( SELECT Orden = ROW_NUMBER () OVER ( PARTITION BY IdSaldo ORDER BY Fecha DESC, IdTransaccion DESC ),
                       IdTransaccion = 0,
                       Operacion = 'SALDO INICIAL',
                       Fecha = @FechaInicio,
                       Descripcion = '',
                       Referencia = '',
                       ChequeFolio = 0,
                       IdCheque = 0,
                       ReferenciaFolioCheque = '',
                       Retiro = 0,
                       Deposito = 0,
                       TipoMovimiento = 0,
                       SalvoBuenCobro = 0,
                       Concepto = CONCAT ('SALDO AL ', @FechaInicio),
                       SaldoAnterior = 0,
                       Saldo,
                       IdCuentaABCD = 0,
                       CuentaABCDcodigo = '',
                       CuentaABCDdescripcion = '',
                       TransaccionIdEstatus = '',
                       EstaConciliada = 0,
                       FechaConciliacion = '1900-01-01',
                       SaldoConciliado = 0,
                       idTipoDDominio,
                       IdSaldo,
                       SaldoVencimiento = '1900-01-01',
                       IdAuxiliar,
                       IdCorte
                FROM dbo.vGRLauxiliarCuentaABCD
                WHERE IdSaldo = @IdSaldo AND Fecha < @FechaInicio ) AS Movimientos
         WHERE Movimientos.Orden = 1 );
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.procedures WHERE object_id = OBJECT_ID ('pLSTauxiliaresCuentaABCD'))
    DROP PROCEDURE pLSTauxiliaresCuentaABCD;
GO


CREATE PROC [dbo].[pLSTauxiliaresCuentaABCD]
@TipoOperacion AS VARCHAR(10) = '',
@FechaCorte AS DATE = '19000101',
@FechaInicio AS DATE = '19000101',
@FechaFin AS DATE = '19000101',
@IdSaldo AS INTEGER = 0,
@SinAfectar AS BIT = 0,
@FechaInicioConciliacion AS DATE = '19000101',
@FechaFinConciliacion AS DATE = '19000101',
@TipoMovimiento AS INTEGER = 0,
@SoloCheques AS BIT = 0,
@IdTipoDDominio AS INT = 0,
@IdAuxiliar AS INT = 0,
@IdCliente AS INT = 0,
@IdEmisorProveedor AS INT = 0,
@IdDeudorAcreedor AS INT = 0,
@IdTipoVista AS INT = 0,
@MostrarSaldosCero AS BIT = 0,
@IdSucursal AS INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SET XACT_ABORT ON;

    DECLARE @SQL AS VARCHAR(MAX);

    SET @SQL = '';

    IF ( @TipoOperacion = 'BANCOS' )
    BEGIN
        IF ( @IdTipoDDominio = 136 ) -------cliente
        BEGIN
            SELECT ISNULL (Saldo.Saldo, 0) AS Saldo,
                   Resumen.Descripcion,
                   Resumen.NIVEL1,
                   Resumen.NIVEL2,
                   Resumen.NIVEL3,
                   Resumen.NIVEL4,
                   Resumen.NIVEL5,
                   Resumen.IdTipoDdominio,
                   Resumen.IdCliente,
                   Resumen.IdSaldo,
                   Resumen.IdEstatusCliente,
                   Resumen.IdAuxiliar,
                   0 AS IdEmisorProveedor
            FROM dbo.vSCSresumenAuxiliarClientes Resumen
            LEFT JOIN dbo.fFNZobtenerSaldosCuentasABCD (@FechaCorte) Saldo ON Saldo.IdSaldoDestino = Resumen.IdSaldo
            WHERE Resumen.IdTipoDdominio = @IdTipoDDominio AND ( @IdCliente = 0 OR ( Resumen.IdCliente = @IdCliente AND NOT @IdCliente = 0 ))
            ORDER BY Resumen.Descripcion,
                     Resumen.NIVEL1,
                     Resumen.NIVEL2,
                     Resumen.NIVEL3,
                     Resumen.NIVEL4,
                     Resumen.NIVEL5;

            RETURN 0;
        END;
        ELSE IF ( @IdTipoDDominio = 137 ) -------------proveedor
        BEGIN
            SELECT ISNULL (Saldo.Saldo, 0) AS Saldo,
                   Resumen.Descripcion,
                   Resumen.NIVEL1,
                   Resumen.NIVEL2,
                   Resumen.NIVEL3,
                   Resumen.NIVEL4,
                   Resumen.NIVEL5,
                   Resumen.IdTipoDdominio,
                   Resumen.IdEmisorProveedor,
                   Resumen.IdSaldo,
                   Resumen.IdEstatusProveedor,
                   Resumen.IdAuxiliar,
                   0 AS IdCliente
            FROM dbo.vSCSresumenAuxiliarProveedores Resumen
            LEFT JOIN dbo.fFNZobtenerSaldosCuentasABCD (@FechaCorte) Saldo ON Saldo.IdSaldoDestino = Resumen.IdSaldo
            WHERE Resumen.IdTipoDdominio IN (137, 1499) AND ( @IdEmisorProveedor = 0 OR ( Resumen.IdEmisorProveedor = @IdEmisorProveedor AND NOT @IdEmisorProveedor = 0 )) AND ( @MostrarSaldosCero = 1 OR ( ISNULL (Saldo.Saldo, 0) <> 0 AND @MostrarSaldosCero = 0 ))
            ORDER BY Resumen.Descripcion,
                     Resumen.NIVEL1,
                     Resumen.NIVEL2,
                     Resumen.NIVEL3,
                     Resumen.NIVEL4,
                     Resumen.NIVEL5;
        END;
        ELSE IF ( @IdTipoDDominio = 700 ) -------------Deudor Acreedor
        BEGIN
            SELECT ISNULL (Saldo.Saldo, 0) AS Saldo,
                   Resumen.Descripcion,
                   Resumen.NIVEL1,
                   Resumen.NIVEL2,
                   Resumen.NIVEL3,
                   Resumen.NIVEL4,
                   Resumen.NIVEL5,
                   Resumen.IdTipoDdominio,
                   Resumen.IdCuentaABCD,
                   Resumen.CuentaABCDcodigo,
                   Resumen.CuentaABCDdescripcion,
                   Resumen.IdSaldo,
                   Resumen.IdEstatusCuentaABCD,
                   Resumen.IdAuxiliar
            FROM dbo.vSDOresumenCuentaABCD Resumen
            LEFT JOIN dbo.fFNZobtenerSaldosCuentasABCD (@FechaCorte) Saldo ON Saldo.IdSaldoDestino = Resumen.IdSaldo
            WHERE Resumen.IdTipoDdominio = @IdTipoDDominio AND ( @IdDeudorAcreedor = 0 OR ( Resumen.IdCuentaABCD = @IdDeudorAcreedor AND NOT @IdDeudorAcreedor = 0 )) AND ( @MostrarSaldosCero = 1 OR ( ISNULL (Saldo.Saldo, 0) <> 0 AND @MostrarSaldosCero = 0 ))
            ORDER BY Resumen.Descripcion,
                     Resumen.NIVEL1,
                     Resumen.NIVEL2,
                     Resumen.NIVEL3,
                     Resumen.NIVEL4,
                     Resumen.NIVEL5;
        END;
        ELSE
        BEGIN
            SET @SQL = 'SELECT 
								ISNULL(f.saldo,0) AS Saldo, c.Descripcion, c.NIVEL1, c.NIVEL2, c.NIVEL3, c.NIVEL4, c.NIVEL5,
								c.IdTipoDdominio, c.IdCuentaABCD, c.CuentaABCDcodigo, c.CuentaABCDdescripcion, c.IdSaldo, c.IdEstatusCuentaABCD,c.IdAuxiliar 
							FROM vSDOresumenCuentaABCD c
							LEFT JOIN dbo.fFNZobtenerSaldosCuentasABCD(''' + CAST(@FechaCorte AS VARCHAR(15)) + ''') f ON f.IdSaldoDestino = c.IdSaldo
							WHERE c.IdTipoDdominio = ' + CAST(@IdTipoDDominio AS VARCHAR(15)) + CASE WHEN @IdSucursal <> 0 THEN ' AND IdSucursal = ' + CAST(@IdSucursal AS VARCHAR(15))
                                                                                                     ELSE ''
                                                                                                END + ' 
							ORDER by c.Descripcion,c.NIVEL1,c.NIVEL2,c.NIVEL3,c.NIVEL4,c.NIVEL5';

            PRINT @SQL;

            EXEC ( @SQL );
        END;
    END;

    IF ( @TipoOperacion = 'CTA' )
    BEGIN
        IF ( @IdTipoDDominio = 136 )
        BEGIN
            IF ( @IdTipoVista = 1 ) ----para el Tipo de Vista de Saldos
            BEGIN
                SELECT IdSaldo,
                       SaldoDescripcion,
                       SaldoFecha,
                       SaldoVencimiento,
                       Cargos = SUM (Deposito),
                       Abonos = SUM (Retiro),
                       Saldo = ( SUM (Deposito) - SUM (Retiro)),
                       Concepto,
                       IdAuxiliar
                FROM dbo.vSCSauxiliarClientesSaldos
                WHERE IdAuxiliar = @IdAuxiliar AND IdCliente = @IdCliente AND TransaccionFecha <= @FechaCorte
                GROUP BY IdSaldo,
                         SaldoDescripcion,
                         SaldoFecha,
                         SaldoVencimiento,
                         Concepto,
                         IdAuxiliar
                HAVING ( @MostrarSaldosCero = 1 OR (( SUM (Deposito) - SUM (Retiro)) <> 0 AND @MostrarSaldosCero = 0 ));

                RETURN 0;
            END;
            ELSE
            BEGIN ------------------Para el Tipo de Vista Historial
                SELECT Auxiliar.Operacion,
                       Auxiliar.Fecha,
                       Auxiliar.Descripcion,
                       Auxiliar.Referencia,
                       Auxiliar.ChequeFolio,
                       Auxiliar.IdCheque,
                       Auxiliar.ReferenciaFolioCheque,
                       Auxiliar.Retiro,
                       Auxiliar.Deposito,
                       Auxiliar.TipoMovimiento,
                       Auxiliar.SalvoBuenCobro,
                       Auxiliar.Concepto,
                       Auxiliar.Saldo,
                       Auxiliar.IdCliente,
                       Auxiliar.TransaccionIdEstatus,
                       Auxiliar.EstaConciliada,
                       Auxiliar.IdAuxiliar,
                       Auxiliar.SaldoAnterior,
                       Auxiliar.FechaConciliacion,
                       Auxiliar.SaldoConciliado,
                       Auxiliar.idTipoDDominio,
                       Auxiliar.IdSaldo,
                       Auxiliar.SaldoVencimiento,
                       IdCorte = 0
                FROM dbo.vSCSauxiliarClientes Auxiliar
                WHERE IdAuxiliar = @IdAuxiliar AND Auxiliar.IdCliente = @IdCliente AND Auxiliar.IdSaldo = @IdSaldo AND ( @FechaInicio = '19000101' AND @FechaFin = '19000101' OR ( Fecha BETWEEN @FechaInicio AND @FechaFin AND NOT ( @FechaInicio = '19000101' AND @FechaFin = '19000101' ))) AND Auxiliar.TransaccionIdEstatus IN ( SELECT splitdata FROM [dbo].[fSplitString] (IIF(@SinAfectar = 0, '1,31', '1,31,13'), ',') ) AND ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' OR ( FechaConciliacion BETWEEN @FechaInicioConciliacion AND @FechaFinConciliacion AND NOT ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' ))) AND ( @TipoMovimiento = 0 OR ( TipoMovimiento = @TipoMovimiento AND NOT @TipoMovimiento = 0 )) AND ( @SoloCheques = 0 OR ( IdCheque <> 0 AND NOT @SoloCheques = 0 ))
                ORDER BY IdSaldo,
                         Fecha,
                         IdTransaccion;

                RETURN 0;
            END;
        END;

        IF ( @IdTipoDDominio = 137 )
        BEGIN
            IF ( @IdTipoVista = 1 ) ----para el Tipo de Vista de Saldos
            BEGIN
                SELECT IdSaldo,
                       SaldoDescripcion,
                       SaldoFecha,
                       SaldoVencimiento,
                       Cargos = SUM (Deposito),
                       Abonos = SUM (Retiro),
                       Saldo = ( SUM (Deposito) - SUM (Retiro)),
                       IdAuxiliar,
                       Concepto
                FROM dbo.vSCSauxiliarProveedoresSaldos
                WHERE IdAuxiliar = @IdAuxiliar AND IdEmisorProveedor = @IdEmisorProveedor AND TransaccionFecha <= @FechaCorte
                GROUP BY IdSaldo,
                         SaldoDescripcion,
                         SaldoFecha,
                         SaldoVencimiento,
                         IdAuxiliar,
                         Concepto
                HAVING ( @MostrarSaldosCero = 1 OR (( SUM (Deposito) - SUM (Retiro)) <> 0 AND @MostrarSaldosCero = 0 ));
            END;
            ELSE
            BEGIN ------------------Para el Tipo de Vista Historial
                SELECT Operacion,
                       Fecha,
                       Proveedor.Descripcion,
                       Proveedor.Referencia,
                       Proveedor.ChequeFolio,
                       Proveedor.IdCheque,
                       Proveedor.ReferenciaFolioCheque,
                       Proveedor.Retiro,
                       Proveedor.Deposito,
                       Proveedor.TipoMovimiento,
                       Proveedor.SalvoBuenCobro,
                       Proveedor.Concepto,
                       Proveedor.Saldo,
                       Proveedor.IdEmisorProveedor,
                       Proveedor.TransaccionIdEstatus,
                       Proveedor.EstaConciliada,
                       IdAuxiliar,
                       Proveedor.SaldoAnterior,
                       Proveedor.FechaConciliacion,
                       Proveedor.SaldoConciliado,
                       Proveedor.IdTipoDdominio,
                       IdSaldo,
                       Proveedor.SaldoVencimiento,
                       0 AS IdCorte
                FROM dbo.vSCSauxiliarProveedores Proveedor
                WHERE IdAuxiliar = @IdAuxiliar AND Proveedor.IdEmisorProveedor = @IdEmisorProveedor AND Proveedor.IdSaldo = @IdSaldo AND ( @FechaInicio = '19000101' AND @FechaFin = '19000101' OR ( Fecha BETWEEN @FechaInicio AND @FechaFin AND NOT ( @FechaInicio = '19000101' AND @FechaFin = '19000101' ))) AND TransaccionIdEstatus IN ( SELECT splitdata FROM [dbo].[fSplitString] (IIF(@SinAfectar = 0, '1,31', '1,31,13'), ',') ) AND ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' OR ( FechaConciliacion BETWEEN @FechaInicioConciliacion AND @FechaFinConciliacion AND NOT ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' ))) AND ( @TipoMovimiento = 0 OR ( TipoMovimiento = @TipoMovimiento AND NOT @TipoMovimiento = 0 )) AND ( @SoloCheques = 0 OR ( IdCheque <> 0 AND NOT @SoloCheques = 0 ))
                ORDER BY Proveedor.IdSaldo,
                         Fecha,
                         IdTransaccion;
            END;
        END;

        IF ( @IdTipoDDominio = 700 )
        BEGIN
            IF ( @IdTipoVista = 1 ) ----para el Tipo de Vista de Saldos
            BEGIN
                SELECT IdSaldo,
                       SaldoDescripcion,
                       SaldoFecha,
                       SaldoVencimiento,
                       Cargos = SUM (Deposito),
                       Abonos = SUM (Retiro),
                       Saldo = ( SUM (Deposito) - SUM (Retiro)),
                       IdAuxiliar,
                       Concepto
                FROM dbo.vGRLauxiliarCuentaABCDsaldos
                WHERE IdSaldo = @IdSaldo AND ( @IdDeudorAcreedor = 0 OR ( IdCuentaABCD = @IdDeudorAcreedor AND NOT @IdDeudorAcreedor = 0 )) AND TransaccionFecha <= @FechaCorte
                GROUP BY IdSaldo,
                         SaldoDescripcion,
                         SaldoFecha,
                         SaldoVencimiento,
                         IdAuxiliar,
                         Concepto
                HAVING ( @MostrarSaldosCero = 1 OR (( SUM (Deposito) - SUM (Retiro)) <> 0 AND @MostrarSaldosCero = 0 ));
            END;
            ELSE
            BEGIN ------------------Para el Tipo de Vista Historial
                SELECT Saldo.Operacion,
                       Saldo.Fecha,
                       Saldo.Descripcion,
                       Saldo.Referencia,
                       Saldo.ChequeFolio,
                       Saldo.IdCheque,
                       Saldo.ReferenciaFolioCheque,
                       Saldo.Retiro,
                       Saldo.Deposito,
                       Saldo.TipoMovimiento,
                       Saldo.SalvoBuenCobro,
                       Saldo.Concepto,
                       Saldo.SaldoAnterior,
                       Saldo.Saldo,
                       Saldo.IdCuentaABCD,
                       Saldo.CuentaABCDcodigo,
                       Saldo.CuentaABCDdescripcion,
                       Saldo.TransaccionIdEstatus,
                       Saldo.EstaConciliada,
                       Saldo.FechaConciliacion,
                       Saldo.SaldoConciliado,
                       Saldo.idTipoDDominio,
                       Saldo.IdSaldo,
                       Saldo.IdAuxiliar,
                       Saldo.SaldoVencimiento,
                       Saldo.IdTransaccion,
                       Saldo.IdCorte
                FROM dbo.FnSDOultimoMovimientoCuentasABCD (@IdSaldo, @FechaInicio) Saldo
                UNION
                SELECT Operacion,
                       Fecha,
                       Auxiliar.Descripcion,
                       Auxiliar.Referencia,
                       Auxiliar.ChequeFolio,
                       Auxiliar.IdCheque,
                       Auxiliar.ReferenciaFolioCheque,
                       Auxiliar.Retiro,
                       Auxiliar.Deposito,
                       Auxiliar.TipoMovimiento,
                       Auxiliar.SalvoBuenCobro,
                       Auxiliar.Concepto,
                       Auxiliar.SaldoAnterior,
                       Auxiliar.Saldo,
                       Auxiliar.IdCuentaABCD,
                       Auxiliar.CuentaABCDcodigo,
                       Auxiliar.CuentaABCDdescripcion,
                       Auxiliar.TransaccionIdEstatus,
                       Auxiliar.EstaConciliada,
                       Auxiliar.FechaConciliacion,
                       Auxiliar.SaldoConciliado,
                       Auxiliar.idTipoDDominio,
                       Auxiliar.IdSaldo,
                       Auxiliar.IdAuxiliar,
                       Auxiliar.SaldoVencimiento,
                       Auxiliar.IdTransaccion,
                       Auxiliar.IdCorte
                FROM dbo.vGRLauxiliarCuentaABCD Auxiliar
                WHERE IdSaldo = @IdSaldo AND ( @FechaInicio = '19000101' AND @FechaFin = '19000101' OR ( Fecha BETWEEN @FechaInicio AND @FechaFin AND NOT ( @FechaInicio = '19000101' AND @FechaFin = '19000101' ))) AND TransaccionIdEstatus IN ( SELECT splitdata FROM [dbo].[fSplitString] (IIF(@SinAfectar = 0, '1,31', '1,31,13'), ',') ) AND ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' OR ( FechaConciliacion BETWEEN @FechaInicioConciliacion AND @FechaFinConciliacion AND NOT ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' ))) AND ( @TipoMovimiento = 0 OR ( TipoMovimiento = @TipoMovimiento AND NOT @TipoMovimiento = 0 )) AND ( @SoloCheques = 0 OR ( IdCheque <> 0 AND NOT @SoloCheques = 0 ))
                ORDER BY IdSaldo,
                         Fecha,
                         IdTransaccion;
            END;
        END;
        ELSE
        BEGIN
            SELECT Saldo.IdTransaccion,
                   Saldo.Operacion,
                   Saldo.Fecha,
                   Saldo.Descripcion,
                   Saldo.Referencia,
                   Saldo.ChequeFolio,
                   Saldo.IdCheque,
                   Saldo.ReferenciaFolioCheque,
                   Saldo.Retiro,
                   Saldo.Deposito,
                   Saldo.TipoMovimiento,
                   Saldo.SalvoBuenCobro,
                   Saldo.Concepto,
                   Saldo.SaldoAnterior,
                   Saldo.Saldo,
                   Saldo.IdCuentaABCD,
                   Saldo.CuentaABCDcodigo,
                   Saldo.CuentaABCDdescripcion,
                   Saldo.TransaccionIdEstatus,
                   Saldo.EstaConciliada,
                   Saldo.FechaConciliacion,
                   Saldo.SaldoConciliado,
                   Saldo.idTipoDDominio,
                   Saldo.IdSaldo,
                   Saldo.SaldoVencimiento,
                   Saldo.IdAuxiliar,
                   Saldo.IdCorte
            FROM dbo.FnSDOultimoMovimientoCuentasABCD (@IdSaldo, @FechaInicio) Saldo
            UNION
            SELECT Auxiliar.IdTransaccion,
                   Auxiliar.Operacion,
                   Auxiliar.Fecha,
                   Auxiliar.Descripcion,
                   Auxiliar.Referencia,
                   Auxiliar.ChequeFolio,
                   Auxiliar.IdCheque,
                   Auxiliar.ReferenciaFolioCheque,
                   Auxiliar.Retiro,
                   Auxiliar.Deposito,
                   Auxiliar.TipoMovimiento,
                   Auxiliar.SalvoBuenCobro,
                   Auxiliar.Concepto,
                   Auxiliar.SaldoAnterior,
                   Auxiliar.Saldo,
                   Auxiliar.IdCuentaABCD,
                   Auxiliar.CuentaABCDcodigo,
                   Auxiliar.CuentaABCDdescripcion,
                   Auxiliar.TransaccionIdEstatus,
                   Auxiliar.EstaConciliada,
                   Auxiliar.FechaConciliacion,
                   Auxiliar.SaldoConciliado,
                   Auxiliar.idTipoDDominio,
                   Auxiliar.IdSaldo,
                   Auxiliar.SaldoVencimiento,
                   Auxiliar.IdAuxiliar,
                   Auxiliar.IdCorte
            FROM dbo.vGRLauxiliarCuentaABCD Auxiliar
            WHERE IdSaldo = @IdSaldo AND ( @FechaInicio = '19000101' AND @FechaFin = '19000101' OR ( Fecha BETWEEN @FechaInicio AND @FechaFin AND NOT ( @FechaInicio = '19000101' AND @FechaFin = '19000101' ))) AND TransaccionIdEstatus IN ( SELECT splitdata FROM [dbo].[fSplitString] (IIF(@SinAfectar = 0, '1,31', '1,31,13'), ',') ) AND ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' OR ( FechaConciliacion BETWEEN @FechaInicioConciliacion AND @FechaFinConciliacion AND NOT ( @FechaInicioConciliacion = '19000101' AND @FechaFinConciliacion = '19000101' ))) AND ( @TipoMovimiento = 0 OR ( TipoMovimiento = @TipoMovimiento AND NOT @TipoMovimiento = 0 )) AND ( @SoloCheques = 0 OR ( IdCheque <> 0 AND NOT @SoloCheques = 0 ))
            ORDER BY IdSaldo,
                     Fecha,
                     IdTransaccion;
        END;
    END;
END;
GO


IF NOT EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tGRLoperacionesDestimacion' )
BEGIN
    CREATE TABLE [dbo].[tGRLoperacionesDestimacion]
    (
        [IdOperacionD] INT NOT NULL,
        [EstimacionCargo] NUMERIC(18, 2) NULL,
        [EstimacionAbono] NUMERIC(18, 2) NULL
    );

    ALTER TABLE [dbo].[tGRLoperacionesDestimacion] WITH CHECK
    ADD CONSTRAINT [FK_tGRLoperacionesD] FOREIGN KEY ( [IdOperacionD] ) REFERENCES [dbo].[tGRLoperacionesD] ( [IdOperacionD] );

    ALTER TABLE [dbo].[tGRLoperacionesDestimacion] CHECK CONSTRAINT [FK_tGRLoperacionesD];
END;

IF NOT EXISTS ( SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tGRLOperacionesCuentasOrden' )
BEGIN
    CREATE TABLE [dbo].[tGRLOperacionesCuentasOrden]
    (
        [IdOperacionCuentasOrden] INT NOT NULL IDENTITY(0, 1),
        [IdOperacion] INT NOT NULL DEFAULT 0,
        [IdTipoDdominio] INT NOT NULL DEFAULT 0,
        [IdTipoOperacion] INT NOT NULL DEFAULT 0,
        [IdEstatusDominio] INT NOT NULL DEFAULT 0,
        [Valor] NUMERIC(18, 2) NULL,
        [Concepto] VARCHAR(80) NULL,
        [Referencia] VARCHAR(30) NULL,
        [IdPersona] INT NOT NULL DEFAULT 0,
        [IdSocio] INT NOT NULL DEFAULT 0,
        [IdCuenta] INT NOT NULL DEFAULT 0,
        [IdBienServicio] INT NOT NULL DEFAULT 0,
        [IdCentroCostos] INT NOT NULL DEFAULT 0,
        [IdDivision] INT NOT NULL DEFAULT 0,
        [IdProyecto] INT NOT NULL DEFAULT 0,
        [IdAuxiliar] INT NOT NULL DEFAULT 0,
        [IdAlmacen] INT NOT NULL DEFAULT 0,
        [IdCuentaABCD] INT NOT NULL DEFAULT 0,
        [IdDivisa] INT NOT NULL DEFAULT 0,
        [IdEntidad1] INT NOT NULL DEFAULT 0,
        [IdEntidad2] INT NOT NULL DEFAULT 0,
        [IdEntidad3] INT NOT NULL DEFAULT 0,
        [IdActivo] INT NOT NULL DEFAULT 0,
        [IdImpuesto] INT NOT NULL DEFAULT 0,
        [IdSucursal] INT NOT NULL DEFAULT 0,
        [IdEstructuraContableE] INT NOT NULL DEFAULT 0,
        [BaseIVA] NUMERIC(18, 2) NULL,
        [IVA] NUMERIC(18, 2) NULL,
        [TasaIVA] NUMERIC(18, 2) NULL,
        [TasaRetencionIVA] NUMERIC(18, 2) NULL,
        [TasaRetencionISR] NUMERIC(18, 2) NULL,
        CONSTRAINT [PK__tGRLOper__36EE1FF68594E8CE] PRIMARY KEY ( [IdOperacionCuentasOrden] ASC )
    );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdOperacion] FOREIGN KEY ( [IdOperacion] ) REFERENCES [dbo].[tGRLoperaciones] ( [IdOperacion] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdOperacion];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdTipoDdominio] FOREIGN KEY ( [IdTipoDdominio] ) REFERENCES [dbo].[tCTLtiposD] ( [IdTipoD] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdTipoDdominio];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdTipoOperacion] FOREIGN KEY ( [IdTipoOperacion] ) REFERENCES [dbo].[tCTLtiposOperacion] ( [IdTipoOperacion] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdTipoOperacion];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdEstatusDominio] FOREIGN KEY ( [IdEstatusDominio] ) REFERENCES [dbo].[tCTLestatus] ( [IdEstatus] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdEstatusDominio];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdPersona] FOREIGN KEY ( [IdPersona] ) REFERENCES [dbo].[tGRLpersonas] ( [IdPersona] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdPersona];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdSocio] FOREIGN KEY ( [IdSocio] ) REFERENCES [dbo].[tSCSsocios] ( [IdSocio] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdSocio];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdCuenta] FOREIGN KEY ( [IdCuenta] ) REFERENCES [dbo].[tAYCcuentas] ( [IdCuenta] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdCuenta];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdBienServicio] FOREIGN KEY ( [IdBienServicio] ) REFERENCES [dbo].[tGRLbienesServicios] ( [IdBienServicio] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdBienServicio];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdCentroCostos] FOREIGN KEY ( [IdCentroCostos] ) REFERENCES [dbo].[tCNTcentrosCostos] ( [IdCentroCostos] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdCentroCostos];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdDivision] FOREIGN KEY ( [IdDivision] ) REFERENCES [dbo].[tCNTdivisiones] ( [IdDivision] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdDivision];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdSucursal] FOREIGN KEY ( [IdSucursal] ) REFERENCES [dbo].[tCTLsucursales] ( [IdSucursal] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdSucursal];

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] WITH CHECK
    ADD CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdEstructuraContableE] FOREIGN KEY ( [IdEstructuraContableE] ) REFERENCES [dbo].[tCNTestructurasContablesE] ( [IdEstructuraContableE] );

    ALTER TABLE [dbo].[tGRLOperacionesCuentasOrden] CHECK CONSTRAINT [FK_tGRLOperacionesCuentasOrden_IdEstructuraContableE];
END;

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vCNToperacionesCuentasOrden'))
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
	   OperacionIdCierre = Operacion.IdCierre
FROM dbo.tGRLOperacionesCuentasOrden CuentaOrden
INNER JOIN dbo.tGRLoperaciones Operacion ON Operacion.IdOperacion = CuentaOrden.IdOperacion
WHERE CuentaOrden.IdOperacionCuentasOrden <> 0;
GO


/* ==========================================
	  Por:  David Vázquez Palestino
	Fecha:  17/11/2020
	=============================================*/
IF EXISTS ( SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vCNToperacionesD'))
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
       Estatus.IdEstatus,
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
       IdEstatusDominio = ISNULL (OperacionD.IdEstatusDominio, 1)
FROM dbo.tGRLoperacionesD OperacionD WITH ( NOLOCK )
INNER JOIN dbo.tCTLestatus Estatus WITH ( NOLOCK ) ON Estatus.IdEstatus = OperacionD.IdEstatus
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH ( NOLOCK ) ON TipoOperacion.IdTipoOperacion = OperacionD.IdTipoSubOperacion
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH ( NOLOCK ) ON BienServicio.IdBienServicio = OperacionD.IdBienServicio
INNER JOIN dbo.tIMPimpuestos Impuesto WITH ( NOLOCK ) ON Impuesto.IdImpuesto = OperacionD.IdImpuesto
INNER JOIN dbo.tGRLoperaciones Operacion WITH ( NOLOCK ) ON Operacion.IdOperacion > 0 AND Operacion.IdOperacion = OperacionD.RelOperacionD
INNER JOIN dbo.tGRLoperaciones OperacionPadre WITH ( NOLOCK ) ON OperacionPadre.IdOperacion = Operacion.IdOperacionPadre
LEFT JOIN dbo.tGRLoperacionesDestimacion OperacionDestimacion WITH ( NOLOCK ) ON OperacionDestimacion.IdOperacionD = OperacionD.IdOperacionD;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.views WHERE object_id = OBJECT_ID ('vCNTtransaccionesImpuestos'))
    DROP VIEW dbo.vCNTtransaccionesImpuestos;
GO


CREATE VIEW [dbo].[vCNTtransaccionesImpuestos]
AS
SELECT Transaccion.IdTransaccionImpuesto,
       Transaccion.IdPersona,
       Transaccion.EfectivamentePagado,
       Transaccion.IdOperacionGenera,
       Transaccion.IdOperacionPago,
       Transaccion.IdOperacionAplica,
       Transaccion.IdOperacionConciliacion,
       Transaccion.IdComprobante,
       Transaccion.Tipo,
       Transaccion.Fecha,
       OperacionPadre.IdPeriodo,
       Transaccion.IdImpuesto,
       BaseIVA = CASE WHEN ROUND (ISNULL (Transaccion.BaseIVA, 0) * Transaccion.FactorDivisa, 2) <> 0 THEN ROUND (ISNULL (Transaccion.BaseIVA, 0) * Transaccion.FactorDivisa, 2)
                      ELSE ROUND (ISNULL (Transaccion.BaseIVApagado, 0) * Transaccion.FactorDivisa, 2) + ROUND (ISNULL (Transaccion.BaseIVAefectivamentePagado, 0) * Transaccion.FactorDivisa, 2)
                 END,
       IVA = CASE WHEN ROUND (ISNULL (Transaccion.IVAgenerado, 0) * Transaccion.FactorDivisa, 2) <> 0 THEN ROUND (ISNULL (Transaccion.IVAgenerado, 0) * Transaccion.FactorDivisa, 2)
                  ELSE ROUND (ISNULL (Transaccion.IVApagado, 0) * Transaccion.FactorDivisa, 2) + ROUND (ISNULL (Transaccion.IVAEfectivamentePagado, 0) * Transaccion.FactorDivisa, 2)
             END,
       IVAgenerado = ROUND (ISNULL (Transaccion.IVAgenerado, 0) * Transaccion.FactorDivisa, 2),
       IVApagado = ROUND (ISNULL (Transaccion.IVApagado, 0) * Transaccion.FactorDivisa, 2),
       IVAEfectivamentePagado = ROUND (ISNULL (Transaccion.IVAEfectivamentePagado, 0) * Transaccion.FactorDivisa, 2),
       DeIVAgenerado = ROUND (ISNULL (Transaccion.DeIVAgenerado, 0) * Transaccion.FactorDivisa, 2),
       DeIVAPagado = ROUND (ISNULL (Transaccion.DeIVAPagado, 0) * Transaccion.FactorDivisa, 2),
       DeIVAefectivamentePagado = ROUND (ISNULL (Transaccion.DeIVAefectivamentePagado, 0) * Transaccion.FactorDivisa, 2),
       Impuesto.TasaIVA,
       Impuesto.TasaRetencionIVA,
       Impuesto.TasaRetencionISR,
       Transaccion.IdOperacionAlta,
       Transaccion.IdSucursal,
       IdCentroCostos = Transaccion.IdCentroCostros,
       Transaccion.IdDivisa,
       Transaccion.IdEstructuraContable,
       Transaccion.IdTipoSubOperacion,
       Transaccion.Alta,
       Transaccion.IdEstatus,
       Transaccion.Naturaleza,
       IdEstructuraContableEimpuesto = Impuesto.IdEstructuraContable,
       OperacionPadre.IdOperacion,
       OperacionPadre.IdTipoOperacion,
       IdTipoDDominioSubOperacion = TipoOperacion.IdTipoDdominio,
       OperacionIdCierre = OperacionPadre.IdCierre,
       OperacionIdCorte = OperacionPadre.IdCorte,
       OperacionPadre.IdListaDPoliza,
       OperacionPadre.TienePoliza,
       IdOperacionTransaccion = Transaccion.IdOperacionAlta,
       IdEstatusDominio = ISNULL (Transaccion.IdEstatus, 1)
FROM dbo.tIMPtransacciones Transaccion
INNER JOIN dbo.tCTLestatus Estatus WITH ( NOLOCK ) ON Estatus.IdEstatus = Transaccion.IdEstatus
INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH ( NOLOCK ) ON TipoOperacion.IdTipoOperacion = Transaccion.IdTipoSubOperacion
INNER JOIN dbo.tIMPimpuestos Impuesto WITH ( NOLOCK ) ON Impuesto.IdImpuesto = Transaccion.IdImpuesto
INNER JOIN dbo.tGRLoperaciones Operacion WITH ( NOLOCK ) ON Operacion.IdOperacion = Transaccion.IdOperacionAlta
INNER JOIN dbo.tGRLoperaciones OperacionPadre WITH ( NOLOCK ) ON OperacionPadre.IdOperacion = Operacion.IdOperacionPadre;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id
            FROM sys.procedures
            WHERE object_id = OBJECT_ID ('pIMPgenerarOperacionesDIngresosGastosPagados'))
    DROP PROCEDURE pIMPgenerarOperacionesDIngresosGastosPagados;
GO


CREATE PROCEDURE dbo.pIMPgenerarOperacionesDIngresosGastosPagados
@IdOperacion INT = NULL
AS
-- 
BEGIN
    SET NOCOUNT ON;

    SET XACT_ABORT ON;

    INSERT INTO dbo.tGRLOperacionesCuentasOrden ( IdOperacion, IdTipoDdominio, IdTipoOperacion, IdEstatusDominio, Valor, BaseIVA, IVA, TasaIVA, TasaRetencionIVA, TasaRetencionISR, Concepto, Referencia, IdPersona, IdSocio, IdCuenta, IdBienServicio, IdCentroCostos, IdDivision, IdProyecto, IdAlmacen, IdCuentaABCD, IdDivisa, IdEntidad1, IdEntidad2, IdEntidad3, IdActivo, IdImpuesto, IdSucursal, IdEstructuraContableE )
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
                                                           ELSE ( Transaccion.SubTotalPagado / Saldo.SubTotalGenerado )
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
    FROM dbo.tSDOtransacciones Transaccion WITH ( NOLOCK )
    INNER JOIN dbo.tSDOsaldos Saldo WITH ( NOLOCK ) ON Saldo.IdSaldo = Transaccion.IdSaldoDestino AND Transaccion.IdTipoSubOperacion = 502
    INNER JOIN dbo.tGRLoperaciones OperacionFactura WITH ( NOLOCK ) ON OperacionFactura.IdOperacion = Saldo.IdOperacion
    INNER JOIN dbo.tGRLoperacionesD Partida WITH ( NOLOCK ) ON OperacionFactura.IdOperacion = Partida.RelOperacionD
    INNER JOIN dbo.tIMPimpuestos Impuesto ON Impuesto.IdImpuesto = Partida.IdImpuesto
    WHERE Saldo.IdTipoDDominioCatalogo <> 700 AND Transaccion.IdEstatus = 1 AND OperacionFactura.IdOperacion <> 0 AND Transaccion.IdOperacion = @IdOperacion AND NOT EXISTS ( SELECT 1
                                                                                                                                                                              FROM dbo.tGRLOperacionesCuentasOrden CuentaOrden WITH ( NOLOCK )
                                                                                                                                                                              WHERE Transaccion.IdOperacion = CuentaOrden.IdOperacion );
END;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.procedures WHERE object_id = OBJECT_ID ('pGRLgeneraOperacionCuentasOrden'))
    DROP PROCEDURE pGRLgeneraOperacionCuentasOrden;
GO


CREATE PROCEDURE dbo.pGRLgeneraOperacionCuentasOrden
@IdOperacion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET XACT_ABORT ON;

    /*CREA LOS REGISTROS PARA CUENTAS DE ORDEN EN INGRESOS Y GASTOS*/
    EXECUTE dbo.pIMPgenerarOperacionesDIngresosGastosPagados @IdOperacion = @IdOperacion; -- int
END;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.procedures WHERE object_id = OBJECT_ID ('pCNTgenerarCadenaAsientos'))
    DROP PROCEDURE pCNTgenerarCadenaAsientos;
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
    DECLARE @filtro VARCHAR(MAX) = CONCAT ('WHERE ', ( SELECT CASE WHEN @TipoFiltro = 2 THEN ' OperacionIdCierre' ELSE 'idOperacion' END ), ' = ', @IdOperacion);
    DECLARE @CamposConValor AS VARCHAR(MAX) = '0 ';
    DECLARE @CaseCampos AS VARCHAR(MAX) = '';
    DECLARE @CaseCampoValor AS VARCHAR(MAX) = '(CASE ';
    DECLARE @Select AS VARCHAR(MAX);
    DECLARE @tmp VARCHAR(MAX) = '';

    -- transacciones
    IF ( @Tipo = 1 )
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

    -- transaccionesFinancieras
    IF ( @Tipo = 2 )
    BEGIN
        --Se omiten las canceladas y las salvobuencobro			
        IF ( @Credito = 1 )
        BEGIN
            SET @CaseCampos = '';
            SET @CaseCampoValor = 'CASE ';

            SELECT @CaseCampoValor = CONCAT (@CaseCampoValor, 'WHEN Campo = ''', ap.Campo, ''' THEN ', ap.Campo, ' ', CHAR (10))
            FROM dbo.vCNTasientosDpolizas ap
            WHERE ap.Origen = 'TFinanciera' AND ap.IdEstatus = 1 AND ap.IdTipoDDominio = 143 AND (( @TipoFiltro = 2 AND NOT IdTipoOperacion IN (6, 14)) OR ( @TipoFiltro = 1 ))
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
            SET @CaseCampos = '';
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

    IF ( @Tipo = 3 ) --OPERACIONES D
    BEGIN
        SET @tmp = CONCAT ('		SELECT *	
									FROM (		SELECT	Tipo = 3, v.IdOperacion, v.OperacionIdCierre, v.OperacionIdCorte, v.IdPeriodo, v.IdListaDPoliza, IdTransaccion = v.IdOperacionD, v.IdTipoOperacion, v.IdTipoSubOperacion, v.IdTipoDDominioSubOperacion, IdTipoDDominio = v.IdTipoDDominioDestino, v.IdEstatusDominio,
																Monto =(CASE WHEN Campo = ''IEPS''			THEN IEPS WHEN Campo = ''IVA''						THEN IVA
																 WHEN Campo = ''ImporteDeduccionExento''	THEN ImporteDeduccionExento WHEN Campo = ''ImporteDeduccionGravado''	THEN ImporteDeduccionGravado 
																 WHEN Campo = ''ImporteExento''				THEN ImporteExento WHEN Campo = ''ImporteGravado''			THEN ImporteGravado 
																 WHEN Campo = ''Impuesto1''					THEN Impuesto1 WHEN Campo = ''Impuesto2''					THEN Impuesto2																 
																 WHEN Campo = ''RetencionImpuesto1''		THEN RetencionImpuesto1 WHEN Campo = ''RetencionImpuesto2''		THEN RetencionImpuesto2 
																 WHEN Campo = ''RetencionISR''				THEN RetencionISR WHEN Campo = ''RetencionIVA''				THEN RetencionIVA 
																 WHEN Campo = ''Salida''					THEN Salida WHEN Campo = ''CostoTotal''				THEN CostoTotal  WHEN Campo = ''Subtotal'' THEN Subtotal 																
																 WHEN Campo = ''Generado''					THEN Generado 
																 WHEN Campo = ''Pagado'' THEN Pagado
																 WHEN Campo = ''EstimacionCargo'' THEN EstimacionCargo
																 WHEN Campo = ''EstimacionAbono'' THEN EstimacionAbono
																 END), IdSucursal, vp.IdAsientoD, IdTipoSubOperacionA =  vp.IdTipoOperacion, IdEstatusDominioA  = vp.IdEstatusDominio
													FROM vCNToperacionesD v
													INNER JOIN vCNTasientosDpolizas vp ON vp.IdEstatus=1 AND NOT v.Idestatus in (18)  AND vp.Origen = ''Partida''																										
																				AND (v.IdTipoSubOperacion=vp.IDTipoOperacion OR vp.IdTipoOperacion=0)
																				AND (v.IdTipoDDominioSubOperacion = vp.IdTipoDDominioSubOperacion OR vp.IdTipoDDominioSubOperacion = 0)
																				AND (v.IdTipoDDominioDestino = vp.IdTipoDDominio   OR vp.IdTipoDDominio   = 0)
																				AND (v.IdEstatusDominio      = vp.IdEstatusDominio OR vp.IdEstatusDominio = 0)
										', @filtro, @FiltroMostrar, ' ) AS con
										WHERE con.Monto <>0 ');
    END;

    IF ( @Tipo = 4 ) --IMPUESTOS
    BEGIN
        --OPCION PARA OPERACIONES
        IF ( @TipoFiltro = 1 )
        BEGIN
            INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA, Naturaleza, NaturalezaA )
            SELECT *
            FROM ( SELECT Tipo = 4,
                          v.IdOperacion,
                          v.OperacionIdCierre,
                          v.OperacionIdCorte,
                          v.IdPeriodo,
                          v.IdListaDPoliza,
                          IdTransaccion = v.IdTransaccionImpuesto,
                          v.IdTipoOperacion,
                          v.IdTipoSubOperacion,
                          v.IdTipoDDominioSubOperacion,
                          IdTipoDDominio = 0,
                          v.IdEstatusDominio,
                          Monto = ( CASE WHEN vp.Campo = 'DeIVAefectivamentePagado' THEN v.DeIVAefectivamentePagado
                                         WHEN vp.Campo = 'DeIVAgenerado' THEN v.DeIVAgenerado
                                         WHEN vp.Campo = 'DeIVApagado' THEN v.DeIVAPagado
                                         WHEN vp.Campo = 'IVAefectivamentePagado' THEN v.IVAEfectivamentePagado
                                         WHEN vp.Campo = 'IVAgenerado' THEN v.IVAgenerado
                                         WHEN vp.Campo = 'IVApagado' THEN v.IVApagado
                                         ELSE NULL
                                    END ),
                          v.IdSucursal,
                          vp.IdAsientoD,
                          IdTipoSubOperacionA = vp.IdTipoOperacion,
                          IdEstatusDominioA = vp.IdEstatusDominio,
                          v.Naturaleza,
                          NaturalezaA = vp.Naturaleza
                   FROM dbo.vCNTtransaccionesImpuestos v
                   JOIN dbo.vCNTasientosDpolizas vp ON vp.IdEstatus = 1 AND NOT v.IdEstatus IN (18, 31, 25, 43) AND vp.IdTipoDDominio <> 143 AND vp.Origen = 'iTransaccion' AND ( vp.Naturaleza = v.Naturaleza OR vp.Naturaleza = 0 )
                   WHERE v.IdOperacion = @IdOperacion ) AS con
            WHERE con.Monto <> 0;
        END;
        ELSE
        --OPCIÓN PARA CIERRES
        BEGIN
            --PRINT 'good z'		
            INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA, Naturaleza, NaturalezaA )
            SELECT *
            FROM ( SELECT Tipo = 4,
                          v.IdOperacion,
                          v.OperacionIdCierre,
                          v.OperacionIdCorte,
                          v.IdPeriodo,
                          v.IdListaDPoliza,
                          IdTransaccion = v.IdTransaccionImpuesto,
                          v.IdTipoOperacion,
                          v.IdTipoSubOperacion,
                          v.IdTipoDDominioSubOperacion,
                          IdTipoDDominio = 0,
                          v.IdEstatusDominio,
                          Monto = ( CASE WHEN vp.Campo = 'DeIVAefectivamentePagado' THEN v.DeIVAefectivamentePagado
                                         WHEN vp.Campo = 'DeIVAgenerado' THEN v.DeIVAgenerado
                                         WHEN vp.Campo = 'DeIVApagado' THEN v.DeIVAPagado
                                         WHEN vp.Campo = 'IVAefectivamentePagado' THEN v.IVAEfectivamentePagado
                                         WHEN vp.Campo = 'IVAgenerado' THEN v.IVAgenerado
                                         WHEN vp.Campo = 'IVApagado' THEN v.IVApagado
                                         ELSE NULL
                                    END ),
                          v.IdSucursal,
                          vp.IdAsientoD,
                          IdTipoSubOperacionA = vp.IdTipoOperacion,
                          IdEstatusDominioA = vp.IdEstatusDominio,
                          v.Naturaleza,
                          NaturalezaA = vp.Naturaleza
                   FROM dbo.vCNTtransaccionesImpuestos v
                   JOIN dbo.vCNTasientosDpolizas vp ON vp.IdEstatus = 1 AND NOT v.IdEstatus IN (18, 31, 25, 43) AND vp.IdTipoDDominio <> 143 AND vp.Origen = 'iTransaccion' AND ( vp.Naturaleza = v.Naturaleza OR vp.Naturaleza = 0 )
                   WHERE v.OperacionIdCierre = @IdOperacion ) AS con
            WHERE con.Monto <> 0;
        END;
    END;

    IF ( @Tipo = 5 ) --GENERALES
    BEGIN
        --OPCION PARA OPERACIONES
        IF ( @TipoFiltro = 1 )
        BEGIN
            INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA )
            SELECT *
            FROM ( SELECT Tipo = 5,
                          v.IdOperacion,
                          v.OperacionIdCierre,
                          v.OperacionIdCorte,
                          v.IdPeriodo,
                          v.IdListaDPoliza,
                          IdTransaccion = v.IdOperacionTransaccion,
                          v.IdTipoOperacion,
                          v.IdTipoSubOperacion,
                          v.IdTipoDDominioSubOperacion,
                          IdTipoDDominio = 0,
                          v.IdEstatusDominio,
                          v.Monto,
                          v.IdSucursal,
                          vp.IdAsientoD,
                          IdTipoSubOperacionA = vp.IdTipoOperacion,
                          IdEstatusDominioA = vp.IdEstatusDominio
                   FROM dbo.vCNToperaciones v
                   JOIN dbo.vCNTasientosDpolizas vp ON vp.IdEstatus = 1 AND vp.IdTipoDDominio <> 143 AND vp.Origen = 'General' AND v.IdTipoDrubro = vp.IdTipoDRubro
                   WHERE v.IdOperacion = @IdOperacion ) AS con
            WHERE con.Monto <> 0;
        END;
        ELSE
        --OPCIÓN PARA CIERRES
        BEGIN
            INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA )
            SELECT *
            FROM ( SELECT Tipo = 5,
                          v.IdOperacion,
                          v.OperacionIdCierre,
                          v.OperacionIdCorte,
                          v.IdPeriodo,
                          v.IdListaDPoliza,
                          IdTransaccion = v.IdOperacionTransaccion,
                          v.IdTipoOperacion,
                          v.IdTipoSubOperacion,
                          v.IdTipoDDominioSubOperacion,
                          IdTipoDDominio = 0,
                          v.IdEstatusDominio,
                          v.Monto,
                          v.IdSucursal,
                          vp.IdAsientoD,
                          IdTipoSubOperacionA = vp.IdTipoOperacion,
                          IdEstatusDominioA = vp.IdEstatusDominio
                   FROM dbo.vCNToperaciones v
                   JOIN dbo.vCNTasientosDpolizas vp ON vp.IdEstatus = 1 AND vp.IdTipoDDominio <> 143 AND vp.Origen = 'General' AND v.IdTipoDrubro = vp.IdTipoDRubro
                   WHERE v.OperacionIdCierre = @IdOperacion ) AS con
            WHERE con.Monto <> 0;
        END;
    END;

    IF ( @Tipo = 6 ) -- CUENTAS DE ORDEN
    BEGIN
        SET @tmp = CONCAT ('SELECT con.Tipo,
								   con.IdOperacion,
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

    IF ( @tmp <> '' )
    BEGIN
        SELECT @sql = @tmp;
    END;
END;
GO


/****************************************************************************************************************************************/

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/

IF EXISTS ( SELECT object_id FROM sys.procedures WHERE object_id = OBJECT_ID ('pCNTgenerarPolizaBaseDatos'))
    DROP PROCEDURE pCNTgenerarPolizaBaseDatos;
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
@DesahabilitarPartidasMultisucursales INT = 0,
@Recontabilizacion BIT = 0,
@Mensaje AS VARCHAR(MAX) = '' OUTPUT,
@MostrarInformacionUsuario AS BIT = 1
AS
--	VERSIÓN 2.1.3
BEGIN
    --Deshabilitamos la devolucion de los valores
    SET NOCOUNT ON;

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @Id INT = ( CASE WHEN @TipoFiltro = 1 THEN @IdOperacion
                             ELSE @IdCierre
                        END );
    DECLARE @UsaMovimientoIntersucursal AS BIT = ISNULL (( SELECT IIF(Valor = 'true', 1, 0)FROM dbo.tCTLconfiguracion WITH ( NOLOCK ) WHERE IdConfiguracion = 17 ), 0);

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

    INSERT INTO #tmpAsientosContableE ( IdEjercicio, IdPeriodo, IdSucursal, Fecha, IdListaDpoliza, Concepto )
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

        INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, Naturaleza, IdTipoDDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdTipoDDominioSubOperacionA, NaturalezaA )
        EXEC ( @sql );

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 1 AND (( c.IdTipoSubOperacionA = 0 ) OR ( c.IdTipoSubOperacionA <> 0 AND c.IdTipoSubOperacionA = c.IdTipoSubOperacion )) AND (( c.IdTipoDDominioSubOperacionA = 0 ) OR ( c.IdTipoDDominioSubOperacionA <> 0 AND c.IdTipoDDominioSubOperacionA = c.IdTipoDDominioSubOperacion )) AND (( NOT c.IdTipoDDominio IN (136, 137, 700)) OR ( c.IdTipoDDominio IN (136, 137, 700) AND c.NaturalezaA = c.Naturaleza ));

        -- clientes, proveedores, deudores

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = f.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            EsCargo = ( CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN 0
                             WHEN c.valor < 0 AND d.EsCargo = 0 THEN 1
                             ELSE d.EsCargo
                        END ),
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

        INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoOperacionA, IdTipoDDominioSubOperacionA, IdEstatusDominioA )
        EXEC ( @sql );

        SET @sql = '';

        --asientosD para crédito
        EXEC dbo.pCNTgenerarCadenaAsientos @Tipo = 2,
                                           @TipoFiltro = @TipoFiltro,
                                           @Credito = 1,
                                           @IdOperacion = @Id,
                                           @sql = @sql OUTPUT,
                                           @MostrarPoliza = @MostrarPoliza;

        INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoOperacionA, IdTipoDDominioSubOperacionA, IdEstatusDominioA )
        EXEC ( @sql );

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 2 AND ((( c.IdTipoOperacionA = 0 ) OR ( IdTipoOperacionA <> 0 AND c.IdTipoOperacionA = c.IdTipoOperacion )) OR ( c.IdTipoOperacion = 41 AND c.IdTipoSubOperacion = c.IdTipoOperacionA AND c.IdTipoOperacionA IN (6, 14))) AND (( c.IdTipoDDominioSubOperacionA = 0 ) OR ( c.IdTipoDDominioSubOperacionA <> 0 AND c.IdTipoDDominioSubOperacionA = c.IdTipoDDominioSubOperacion )) AND (( c.IdEstatusDominioA = 0 ) OR ( c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio ));

        --Actualizamos otros campos
        UPDATE c
        SET IdPeriodo = f.IdPeriodo,
            Inverso = IIF(c.valor < 0, 1, NULL),
            IdEstructuraContableE = IIF(d.EsImpuestos = 1, f.IdEstructuraContableEimpuesto, f.IdEstructuraContableE),
            IdCentroCostos = f.IdCentroCostos,
            IdTipoDRubro = d.IdTipoDRubro,
            EsImpuestos = d.EsImpuestos,
            IdImpuesto = f.IdImpuesto,
            IdTipoDImpuesto = IIF(d.EsImpuestos = 1, d.IdTipoDImpuesto, NULL),
            IdDivisa = f.IdDivisa,
            IdDivision = f.IdDivision,
            IdAuxiliar = f.IdAuxiliar,
            IdSucursal = f.IdSucursal,
            EsCargo = ( CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN 0
                             WHEN c.valor < 0 AND d.EsCargo = 0 THEN 1
                             ELSE d.EsCargo
                        END )
        FROM #tmpAsientosContableD c
        INNER JOIN dbo.vCNTasientosDpolizas d ON d.IdAsientoD = c.idAsientoD
        INNER JOIN dbo.vCNTtransaccionesF f ON f.IdTransaccion = c.IdTransaccion
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

        INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdCierre, IdCorte, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoSubOperacion, IdTipoDDominioSubOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA )
        EXEC ( @sql );

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 3 AND (( c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoSubOperacion )) AND (( c.IdEstatusDominioA = 0 ) OR ( c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio ));

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
            EsCargo = ( CASE WHEN c.valor < 0 AND AsientoPoliza.EsCargo = 1 THEN 0
                             WHEN c.valor < 0 AND AsientoPoliza.EsCargo = 0 THEN 1
                             ELSE AsientoPoliza.EsCargo
                        END )
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
        WHERE Tipo = 4 AND (( c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoSubOperacion )) AND (( c.IdEstatusDominioA = 0 ) OR ( c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio ));

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
            EsCargo = ( CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN 0
                             WHEN c.valor < 0 AND d.EsCargo = 0 THEN 1
                             ELSE d.EsCargo
                        END ),
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
        WHERE Tipo = 5 AND (( c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoSubOperacion )) AND (( c.IdEstatusDominioA = 0 ) OR ( c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio ));

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
            EsCargo = ( CASE WHEN c.valor < 0 AND d.EsCargo = 1 THEN 0
                             WHEN c.valor < 0 AND d.EsCargo = 0 THEN 1
                             ELSE d.EsCargo
                        END )
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

        INSERT INTO #tmpAsientosContableD ( Tipo, IdOperacion, IdPeriodo, IdListaDpoliza, IdTransaccion, IdTipoOperacion, IdTipoDDominio, IdEstatusDominio, valor, IdSucursal, idAsientoD, IdTipoSubOperacionA, IdEstatusDominioA )
        EXEC ( @sql );

        UPDATE c
        SET EsValida = 1
        FROM #tmpAsientosContableD c
        WHERE Tipo = 6 AND (( c.IdTipoSubOperacionA = 0 OR c.IdTipoSubOperacionA = c.IdTipoOperacion )) AND (( c.IdEstatusDominioA = 0 ) OR ( c.IdEstatusDominioA <> 0 AND c.IdEstatusDominioA = c.IdEstatusDominio ));

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
            EsCargo = ( CASE WHEN c.valor < 0 AND AsientoD.EsCargo = 1 THEN 0
                             WHEN c.valor < 0 AND AsientoD.EsCargo = 0 THEN 1
                             ELSE AsientoD.EsCargo
                        END ),
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
    IF EXISTS ( SELECT TOP ( 1 ) Tipo FROM #tmpAsientosContableD )
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
        WHERE e.IdTipoDRubro = c.IdTipoDRubro AND (( e.TipoDivisaDivision = 0 AND e.IdTipoDimpuesto = c.IdTipoDImpuesto ) OR ( e.TipoDivisaDivision = 2 AND e.IdDivisa = c.IdDivisa ) OR ( e.TipoDivisaDivision = 1 AND e.IdDivision = c.IdDivision ) OR ( e.TipoDivisaDivision = 3 AND e.IdDivisa = c.IdDivisa AND e.IdAuxiliar = c.IdAuxiliar ) OR ( e.TipoDivisaDivision = 4 AND e.IdDivision = c.IdDivision AND e.IdBienServicio = c.IdBienServicio ));
    END;

    INSERT INTO #tmpAsientosOperaciones ( IdOperacion, IdEjercicio, IdPeriodo, IdListaDpoliza, IdSucursalPrincipal, Cargos, Abonos )
    SELECT e.IdOperacion,
           Periodo.IdEjercicio,
           e.IdPeriodo,
           e.IdListaDpoliza,
           ( SELECT TOP ( 1 ) IdSucursal
             FROM #tmpAsientosContableD b
             WHERE b.EsValida = 1 AND Tipo <> 3 AND b.IdOperacion = e.IdOperacion
             ORDER BY b.Tipo,
                      b.IdTransaccion ) AS IdSucursalPrincipal,
           Cargos = SUM (e.Cargo),
           Abonos = SUM (e.Abono)
    FROM #tmpAsientosContableD e
    INNER JOIN dbo.tCTLperiodos Periodo ON Periodo.IdPeriodo = e.IdPeriodo
    GROUP BY e.IdOperacion,
             Periodo.IdEjercicio,
             e.IdPeriodo,
             e.IdListaDpoliza;

    IF ( @DesahabilitarPartidasMultisucursales <> 999 )
    BEGIN
        IF ( @UsaMovimientoIntersucursal = 1 )
        BEGIN
            UPDATE t
            SET IdSucursalPrincipal = tmp.IdSucursalPrincipal
            FROM #tmpAsientosContableD t
            INNER JOIN #tmpAsientosOperaciones AS tmp ON tmp.IdOperacion = t.IdOperacion;

            /*
				GENERAMOS LOS MOVIMIENTOS INTERSUCURSAL
			*/
            INSERT INTO #tmpAsientosContableD ( Tipo, IdTransaccion, IdOperacion, IdPeriodo, IdListaDpoliza, IdSucursal, IdSucursalPrincipal, EsCargo, Cargo, Abono, EsIntersucursal, EsValida, IdImpuesto, IdAsientoD )
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
            FROM ( SELECT IdOperacion,
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
                            IdSucursalPrincipal ) AS x
            WHERE ABS (cambioNeto) > 0;

            INSERT INTO #tmpAsientosContableD ( Tipo, IdTransaccion, IdOperacion, IdPeriodo, IdListaDpoliza, IdSucursal, IdSucursalPrincipal, EsCargo, Cargo, Abono, EsIntersucursal, EsValida, IdImpuesto, IdAsientoD )
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
            DECLARE @IdcuentaContable INT = ISNULL (( SELECT tc.IdCuentaContable
                                                      FROM dbo.tCNTcuentas tc
                                                      WHERE tc.Codigo <> '' AND Codigo = ( SELECT tc.ValorCodigo FROM dbo.tCTLconfiguracion tc WHERE tc.IdConfiguracion = 18 )), 0);

            IF ( @IdcuentaContable <> 0 )
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
    INNER JOIN ( SELECT e.Id,
                        ROW_NUMBER () OVER ( PARTITION BY e.IdPeriodo, e.IdListaDpoliza ORDER BY c.Codigo ) AS partida
                 FROM #tmpAsientosContableD e
                 INNER JOIN dbo.tCNTcuentas c ON c.IdCuentaContable = e.IdCuentaContable
                 WHERE e.EsValida = 1 ) AS tmp ON tmp.Id = t.Id;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional ( Tipo, IdTransaccionPoliza, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdCliente, IdClienteFiscal, IdEmisorProveedor, IdProveedorFiscal, IdBienServicio, IdCuentaABCD, IdDivisa, IdOperacion, IdTransaccion, IdSucursal, Concepto, Referencia, IdSaldoDestino, IdOperacionTransaccion )
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
        INSERT INTO #tmpAsientosContableDatosAdicional ( Tipo, IdTransaccionPoliza, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdSocio, IdBienServicio, IdDivision, IdDivisa, IdOperacion, IdTransaccionFinanciera, IdSucursal, Concepto, Referencia, IdSaldoDestino, IdOperacionTransaccion )
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
        INSERT INTO #tmpAsientosContableDatosAdicional ( Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdOperacionDOrigen, IdSucursal, Concepto, Referencia, IdOperacionTransaccion )
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
                        OperacionD.IdOperacionTransaccion
        FROM dbo.vCNToperacionesD OperacionD
        INNER JOIN #tmpAsientosContableD tmp ON tmp.IdTransaccion = OperacionD.IdOperacionD
        WHERE tmp.Tipo = 3 AND tmp.EsValida = 1;
    END;

    BEGIN
        INSERT INTO #tmpAsientosContableDatosAdicional ( Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdTransaccion, IdSucursal, Concepto, Referencia, IdOperacionTransaccion, IdPersona, IdTransaccionImpuesto )
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
        INSERT INTO #tmpAsientosContableDatosAdicional ( Tipo, IdTransaccionPoliza, IdProyecto, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdBienServicio, IdAlmacen, IdDivision, IdOperacion, IdSucursal, Concepto, Referencia, IdPersona, IdOperacionTransaccion, IdOperacionCuentasOrden )
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
    IF ( @MostrarPoliza = 1 AND @MostrarInformacionUsuario = 0 )
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
        RIGHT JOIN ( SELECT tmp.Id,
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
                     JOIN dbo.tCNTasientosD AsientoD WITH ( NOLOCK ) ON AsientoD.IdAsientoD = tmp.idAsientoD
                     JOIN dbo.tCNTcuentas Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuentaContable = tmp.IdCuentaContable
                     JOIN dbo.tCTLtiposD Rubro WITH ( NOLOCK ) ON Rubro.IdTipoD = AsientoD.IdTipoDRubro ) AS tmp ON tmp.Tipo = AsientoContableAdicional.Tipo AND tmp.IdTransaccion = AsientoContableAdicional.IdTransaccionPoliza
        ORDER BY tmp.IdPeriodo,
                 tmp.IdListaDpoliza,
                 tmp.Partida;

        IF @IdCierre <> 0
        BEGIN
            SELECT t.IdOperacion,
                   Cargo = SUM (tmp.Cargo),
                   Abono = SUM (tmp.Abono)
            FROM #tmpAsientosContableDatosAdicional t
            RIGHT JOIN ( SELECT tmp.Id,
                                tmp.Tipo,
                                tmp.IdTransaccion,
                                tmp.idAsientoD,
                                tmp.IdCuentaContable,
                                tmp.Cargo,
                                tmp.Abono
                         FROM #tmpAsientosContableD tmp
                         JOIN dbo.tCNTasientosD AsientoD WITH ( NOLOCK ) ON AsientoD.IdAsientoD = tmp.idAsientoD
                         JOIN dbo.tCNTcuentas Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuentaContable = tmp.IdCuentaContable
                         JOIN dbo.tCTLtiposD Rubro WITH ( NOLOCK ) ON Rubro.IdTipoD = AsientoD.IdTipoDRubro ) AS tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
            WHERE tmp.Partida <> 0
            GROUP BY t.IdOperacion
            HAVING ( SUM (tmp.Cargo) - SUM (tmp.Abono)) <> 0;
        END;

        DECLARE @IdTipoOperacion INT;

        IF ( @TipoFiltro = 1 )
            SELECT @IdTipoOperacion = IdTipoOperacion
            FROM dbo.tGRLoperaciones WITH ( NOLOCK )
            WHERE IdOperacion = @IdOperacion;

        IF ( @IdTipoOperacion = 4 OR @IdTipoOperacion = 503 )
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
    IF ( @MostrarPoliza = 1 AND @MostrarInformacionUsuario = 1 )
    BEGIN
        SELECT tmp.EsIntersucursal,
               tmp.Partida,
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
               [Proveedor] = prov.Nombre,
               t.IdPersona,
               tmp.EsValida
        FROM #tmpAsientosContableDatosAdicional t
        LEFT JOIN dbo.tCNTauxiliares auxiliar ON auxiliar.IdAuxiliar = t.IdAuxiliar
        LEFT JOIN dbo.tCNTdivisiones division ON division.IdDivision = t.IdDivision
        LEFT JOIN dbo.tCTLsucursales sucursal ON sucursal.IdSucursal = t.IdSucursal
        LEFT JOIN dbo.tGRLbienesServicios bien WITH ( NOLOCK ) ON t.IdBienServicio = bien.IdBienServicio
        LEFT JOIN dbo.vSCSemisoresProveedores prov ON prov.IdEmisorProveedor = t.IdEmisorProveedor
        RIGHT JOIN ( SELECT tmp.*,
                            AsientoD.Campo,
                            Rubro.Descripcion AS rubro,
                            Cuenta.Codigo AS cuenta,
                            Cuenta.Descripcion AS nombreCuenta
                     FROM #tmpAsientosContableD tmp
                     INNER JOIN dbo.tCNTasientosD AsientoD WITH ( NOLOCK ) ON AsientoD.IdAsientoD = tmp.idAsientoD
                     INNER JOIN dbo.tCNTcuentas Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuentaContable = tmp.IdCuentaContable
                     INNER JOIN dbo.tCTLtiposD Rubro WITH ( NOLOCK ) ON Rubro.IdTipoD = AsientoD.IdTipoDRubro ) AS tmp ON tmp.Tipo = t.Tipo AND tmp.IdTransaccion = t.IdTransaccionPoliza
        LEFT JOIN dbo.tCNTestructurasContablesE EstructuraContableE ON EstructuraContableE.IdEstructuraContableE = tmp.IdEstructuraContableE
        WHERE tmp.Partida IS NOT NULL
        ORDER BY tmp.IdPeriodo,
                 tmp.IdListaDpoliza,
                 tmp.Partida;

        IF ( @TipoFiltro = 1 )
            SELECT @IdTipoOperacion = IdTipoOperacion
            FROM dbo.tGRLoperaciones WITH ( NOLOCK )
            WHERE IdOperacion = @IdOperacion;

        IF ( @IdTipoOperacion = 4 OR @IdTipoOperacion = 503 )
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
    IF ( @DesahabilitarPartidasMultisucursales <> 999 )
    BEGIN
        IF ( @UsaMovimientoIntersucursal = 1 )
        BEGIN
            IF EXISTS ( SELECT tmp.IdPeriodo,
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

    IF EXISTS ( SELECT IdSucursal FROM #tmpAsientosContableD WHERE EsValida = 1 AND IdSucursal = 0 )
    BEGIN
        SET @Mensaje = CONCAT ('Registros con sucursal cero ID(', @IdOperacion, ')');

        SELECT @Mensaje;

        SET @IdEstatusPoliza = 34;

        RETURN -1;
    END;

    IF EXISTS ( SELECT IdSucursal FROM #tmpAsientosContableD WHERE EsValida = 1 AND IdCuentaContable = 0 )
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
    JOIN ( SELECT IdPeriodo,
                  IdListaDpoliza,
                  Partidas = COUNT (*),
                  Cargos = SUM (tmp.Cargo),
                  Abonos = SUM (tmp.Abono),
                  IdEstatus = IIF(SUM (tmp.Cargo) = SUM (tmp.Abono), 1, 13)
           FROM #tmpAsientosContableD tmp
           WHERE EsValida = 1
           GROUP BY IdPeriodo,
                    IdListaDpoliza ) AS x ON x.IdPeriodo = e.IdPeriodo AND x.IdListaDpoliza = e.IdListaDpoliza;

    DECLARE @numeroPartidasValidas AS INT = ( SELECT COUNT (*) FROM #tmpAsientosContableE WHERE Idestatus = 1 );

    IF ( @numeroPartidasValidas = 0 )
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
            IF ( @Recontabilizacion = 1 )
            BEGIN
                IF ( @TipoFiltro = 1 AND @IdOperacion <> 0 )
                BEGIN
                    IF EXISTS ( SELECT 1
                                FROM dbo.tCNTpolizasFoliosOperaciones wt
                                WHERE @TipoFiltro = 1 AND IdOperacion = @IdOperacion AND @IdOperacion <> 0 AND IdListaDPoliza = @IdListaDpoliza AND @IdPolizaE <> 0 )
                    BEGIN
                        PRINT 'SE ULTIZA EL FOLIO ORIGINAL';

                        UPDATE PolizaE
                        SET Folio = tmp.Folio
                        FROM dbo.tCNTpolizasE PolizaE
                        JOIN ( SELECT IdPolizaE = @IdPolizaE,
                                      Folio,
                                      Numero = ROW_NUMBER () OVER ( ORDER BY Principal DESC )
                               FROM dbo.tCNTpolizasFoliosOperaciones
                               WHERE IdOperacion = @IdOperacion AND IdListaDPoliza = @IdListaDpoliza ) tmp ON tmp.IdPolizaE = PolizaE.IdPolizaE AND tmp.Numero = 1;
                    END;
                END;
                ELSE
                BEGIN
                    IF ( @TipoFiltro = 2 AND @IdCierre <> 0 )
                    BEGIN
                        IF EXISTS ( SELECT 1
                                    FROM dbo.tCNTpolizasFoliosOperaciones
                                    WHERE @TipoFiltro = 2 AND IdCierre = @IdCierre AND @IdCierre <> 0 AND IdListaDPoliza = @IdListaDpoliza AND @IdPolizaE <> 0 )
                        BEGIN
                            PRINT 'SE ULTIZA EL FOLIO ORIGINAL';

                            UPDATE PolizaE
                            SET Folio = tmp.Folio
                            FROM dbo.tCNTpolizasE PolizaE
                            JOIN ( SELECT IdPolizaE = @IdPolizaE,
                                          Folio,
                                          Numero = ROW_NUMBER () OVER ( ORDER BY Principal DESC )
                                   FROM dbo.tCNTpolizasFoliosOperaciones
                                   WHERE IdCierre = @IdCierre AND IdListaDPoliza = @IdListaDpoliza ) tmp ON tmp.IdPolizaE = PolizaE.IdPolizaE AND tmp.Numero = 1;
                        END;
                    END;
                END;
            END;

            PRINT @IdPolizaE;

            IF ( NOT @IdPolizaE IS NULL )
            BEGIN
                /*Agregamos los detalles por periodo - tipo de póliza*/
                INSERT dbo.tCNTpolizasD ( IdPolizaE, Partida, IdCuentaContable, IdCentroCostos, Cargo, Abono, BaseIVA, IVA, TasaIVA, TasaRetencionIVA, TasaRetencionISR, IdProyecto, IdCuenta, IdAuxiliar, IdEntidad1, IdEntidad2, IdEntidad3, IdPersona, IdSocio, IdCliente, IdClienteFiscal, IdEmisorProveedor, IdProveedorFiscal, IdBienServicio, IdAlmacen, IdDivision, IdCuentaABCD, IdDivisa, IdEstructuraContableD, IdOperacion, IdOperacionDOrigen, IdTransaccion, IdTransaccionFinanciera, IdSucursal, IdAsientoD, IdSaldoDestino, Concepto, Referencia, IdImpuesto, IdTransaccionImpuesto, IdOperacionCuentasOrden )
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
        DECLARE @idtipox AS INT = ( SELECT TOP ( 1 ) o.IdTipoOperacion
                                    FROM dbo.tGRLoperaciones o WITH ( NOLOCK )
                                    WHERE o.IdOperacion = @IdOperacion AND @IdCierre = 0 );

        IF ( @idtipox = 25 )
        BEGIN
            RETURN -1;
        END;

        SET @IdEstatusPoliza = 34;
        SET @Mensaje = ( SELECT CONCAT ('CodEx|01944|pAYCejecutarProvisionAcreedoras|', ' ERROR_NUMBER: ', ERROR_NUMBER (), ' ERROR_SEVERITY: ', ERROR_SEVERITY (), ' ERROR_STATE: ', ERROR_STATE (), ' ERROR_PROCEDURE: ', ERROR_PROCEDURE (), ' ERROR_LINE: ', ERROR_LINE (), ' ERROR_MESSAGE', ERROR_MESSAGE ()));

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


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.procedures WHERE object_id = OBJECT_ID ('pCNTrecontabilizacionOperacion'))
    DROP PROCEDURE pCNTrecontabilizacionOperacion;
GO


CREATE PROC [pCNTrecontabilizacionOperacion]
@IdOperacion INT,
@LanzarError AS BIT = 1
AS
BEGIN
    IF @IdOperacion <> 0
    BEGIN
        DECLARE @RequierePoliza AS BIT = ISNULL (( SELECT TOP ( 1 ) RequierePoliza
                                                   FROM dbo.tGRLoperaciones WITH ( NOLOCK )
                                                   WHERE IdOperacion = @IdOperacion
                                                   ORDER BY IdOperacion ), 0);

        IF @RequierePoliza = 0
        BEGIN
            RETURN 0;
        END;
    END;

    IF EXISTS ( SELECT 1 FROM dbo.tGRLoperaciones WITH ( NOLOCK ) WHERE IdTipoOperacion = 510 AND IdOperacion = @IdOperacion )
    BEGIN
        --RETURN
        PRINT ( 'factura' );
    END;

    DECLARE @idestatus     INT,
            @idsucursal    INT,
            @idsesion      INT,
            @idusuario     INT,
            @ModuloAbierto BIT,
            @idpolizaE     INT,
            @idcierre      INT;
    DECLARE @Mensaje AS VARCHAR(MAX) = '';
    DECLARE @CadError AS VARCHAR(MAX) = '';

    IF ( @IdOperacion = 0 )
        RETURN 0;

    -- provisional 
    DECLARE @idtipooperacionx INT;

    SELECT @idcierre = Operacion.IdCierre,
           @idpolizaE = Operacion.IdPolizaE,
           @idestatus = Operacion.IdEstatus,
           @idsucursal = Operacion.IdSucursal,
           @idsesion = Operacion.IdSesion,
           @idusuario = Operacion.IdUsuarioAlta,
           @ModuloAbierto = Periodo.Abierto,
           @idtipooperacionx = Operacion.IdTipoOperacion
    FROM dbo.tGRLoperaciones Operacion WITH ( NOLOCK )
    JOIN dbo.vCTLperiodosModulos Periodo WITH ( NOLOCK ) ON Periodo.IdPeriodo = Operacion.IdPeriodo AND Periodo.IdModulo = 2
    JOIN ( SELECT DISTINCT IdOperacion = tg.IdOperacionPadre,
                           IdSucursal
           FROM dbo.tGRLoperaciones tg WITH ( NOLOCK )
           WHERE IdCierre = 0 AND tg.IdTipoDregistro = 0 AND IdEstatus = 1 AND RequierePoliza = 1 AND tg.IdOperacion = @IdOperacion ) AS tmp ON tmp.IdOperacion = Operacion.IdOperacion
    ORDER BY Operacion.IdOperacion,
             Operacion.Fecha;

    IF ( @idcierre <> 0 )
    BEGIN
        SET @Mensaje = CONCAT ('NO ES POSIBLE RECONTABILIZAR UNA OPERACION QUE PERTENECE A UN CIERRE: ', @idcierre);

        SELECT Mensaje = @Mensaje;

        IF @LanzarError = 1
        BEGIN
            SET @CadError = CONCAT ('CodEx|02066|CRUDtransaccionesFinancieras|', @Mensaje);

            RAISERROR (@CadError, 16, 8);
        END;

        RETURN 0;
    END;

    IF ( @idestatus <> 1 )
    BEGIN
        SET @Mensaje = CONCAT ('NO ES POSIBLE RECONTABILIZAR UNA OPERACION CON UN ESTATUS DIFERENTE A ACTIVO, Estatus:', @idestatus);

        SELECT Mensaje = @Mensaje;

        IF @LanzarError = 1
        BEGIN
            SET @CadError = CONCAT ('CodEx|02066|CRUDtransaccionesFinancieras|', @Mensaje);

            RAISERROR (@CadError, 16, 8);
        END;

        RETURN 0;
    END;

    IF ( @ModuloAbierto = 0 )
    BEGIN
        SET @Mensaje = 'EL MÓDULO CONTABLE NO ESTA ABIERTO PARA EL PERIODO';

        SELECT Mensaje = @Mensaje;

        IF @LanzarError = 1
        BEGIN
            SET @CadError = CONCAT ('CodEx|02066|CRUDtransaccionesFinancieras|', @Mensaje);

            RAISERROR (@CadError, 16, 8);
        END;

        RETURN 0;
    END;

    DECLARE @IdEstatusPoliza INT = 0;

    IF EXISTS ( SELECT IdPolizaE
                FROM dbo.tGRLoperaciones Operacion WITH ( NOLOCK )
                WHERE IdPolizaE <> 0 AND IdOperacion = @IdOperacion )
    BEGIN
        -- Borramos la póliza contable, si el estatus es 7, la operacion fue correcta
        EXEC dbo.pCNTpolizaContableOperaciones @TipoOperacion = 'OPERACION',
                                               @IdCierre = 0,
                                               @IdOperacion = @IdOperacion,
                                               @IdEstatusOperacion = @IdEstatusPoliza OUTPUT;

        IF @IdEstatusPoliza <> 7
        BEGIN
            SET @Mensaje = 'NO FUE POSIBLE ELIMINAR LA PÓLIZA CONTABLE';

            SELECT Mensaje = @Mensaje;

            IF @LanzarError = 1
            BEGIN
                SET @CadError = CONCAT ('CodEx|02066|CRUDtransaccionesFinancieras|', @Mensaje);

                RAISERROR (@CadError, 16, 8);
            END;

            RETURN 0;
        END;
    END;

    PRINT 'RECONTABILIZANDO';

    EXEC [dbo].[pCNTgenerarPolizaBaseDatos] @TipoFiltro = 1,
                                            @IdOperacion = @IdOperacion,
                                            @IdCierre = 0,
                                            @IdSucursal = @idsucursal,
                                            @IdUsuario = @idusuario,
                                            @IdSesion = @idsesion,
                                            @IdEstatusPoliza = @IdEstatusPoliza OUTPUT,
                                            @NoAcumular = 1,
                                            --Con este párametro reutilizamos el Folio de la póliza borrada
                                            @Recontabilizacion = 1,
                                            @Mensaje = @Mensaje OUTPUT;

    IF ( @IdEstatusPoliza = 1 )
    BEGIN
        SELECT Mensaje = CONCAT ('SE RECONTABILIZO LA OPERACION', @IdOperacion, ' CORRECTAMENTE');

        RETURN 0;
    END;

    --provisionalmente para CPO 10 de enero del 2018
    IF ( @idtipooperacionx IN (518, 8))
        RETURN 0;

    IF ( @IdEstatusPoliza <> 1 )
    BEGIN
        SELECT Mensaje = @Mensaje;

        IF @LanzarError = 1
        BEGIN
            SET @CadError = CONCAT ('CodEx|02066|CRUDtransaccionesFinancieras|', @Mensaje);

            RAISERROR (@CadError, 16, 8);
        END;

        RETURN 0;
    END;
END;
GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  17/11/2020
=============================================*/
IF EXISTS ( SELECT object_id FROM sys.procedures WHERE object_id = OBJECT_ID ('pDnFNZingresosPeriodo'))
    DROP PROCEDURE pDnFNZingresosPeriodo;
GO




CREATE PROCEDURE dbo.pDnFNZingresosPeriodo
@Periodo VARCHAR(8) = ''
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SET NOCOUNT ON;

    DECLARE @IdPeriodo INT;

    SELECT @IdPeriodo = IdPeriodo
    FROM dbo.tCTLperiodos WITH ( NOLOCK )
    WHERE Codigo = @Periodo;

    SELECT Periodo.Codigo AS Período,
           TipoPoliza.Codigo AS [Tipo de Póliza],
           Poliza.Folio AS [Folio Póliza],
           Poliza.Fecha,        
           TipoOperacion = TipoOperacion.Descripcion,
           Folio = CONCAT (Operacion.Serie, Operacion.Folio),
           TipoAIC.Descripcion AS Clasificación,
           CuentaContable.Codigo AS [Cuenta Contable],
           CuentaContable.Descripcion AS [Descripción],
           PolizaD.Concepto,
           PolizaD.Referencia,
           [Tipo Ingreso] = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN 'INTERÉS MORATORIO'
                                 WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN 'INTERÉS ORDINARIO'
                                 ELSE BienServicio.Descripcion
                            END,
           PolizaD.Abono - PolizaD.Cargo AS Importe,
           Tasa = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN ImpuestoTransaccionFinanciera.TasaIVA
                       ELSE ImpuestoOperacionD.TasaIVA
                  END,
           IVA = CASE WHEN AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido') THEN TransaccionFinanciera.IVAInteresMoratorioPagado
                      WHEN AsientoD.Campo IN ('InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') THEN TransaccionFinanciera.IVAInteresOrdinarioPagado
                      ELSE OperacionD.IVA
                 END,
           Persona.Nombre AS [Socio/cliente],
           Persona.RFC,
           Division.Descripcion AS División,
           Sucursal.Descripcion AS Sucursal,
           CONCAT (Cuenta.Descripcion, ' ', Cuenta.Codigo) AS Crédito
    FROM dbo.tCNTpolizasE Poliza WITH ( NOLOCK )
    INNER JOIN dbo.tCATlistasD TipoPoliza WITH ( NOLOCK ) ON TipoPoliza.IdListaD = Poliza.IdListaDpoliza
    INNER JOIN dbo.tCTLperiodos Periodo WITH ( NOLOCK ) ON Periodo.IdPeriodo = Poliza.IdPeriodo
    INNER JOIN dbo.tCNTpolizasD PolizaD WITH ( NOLOCK ) ON Poliza.IdPolizaE = PolizaD.IdPolizaE
    INNER JOIN dbo.tCNTasientosD AsientoD WITH ( NOLOCK ) ON AsientoD.IdAsientoD = PolizaD.IdAsientoD
    INNER JOIN dbo.tGRLoperaciones Operacion WITH ( NOLOCK ) ON Operacion.IdOperacion = PolizaD.IdOperacion
    INNER JOIN dbo.tCTLtiposOperacion TipoOperacion WITH ( NOLOCK ) ON TipoOperacion.IdTipoOperacion = Operacion.IdTipoOperacion
    INNER JOIN dbo.tCNTcuentas CuentaContable WITH ( NOLOCK ) ON CuentaContable.IdCuentaContable = PolizaD.IdCuentaContable
    INNER JOIN dbo.tAYCcuentas Cuenta WITH ( NOLOCK ) ON Cuenta.IdCuenta = PolizaD.IdCuenta
    INNER JOIN dbo.tCTLtiposD TipoAIC WITH ( NOLOCK ) ON TipoAIC.IdTipoD = Cuenta.IdTipoDAIC
    INNER JOIN dbo.tGRLpersonas Persona WITH ( NOLOCK ) ON Persona.IdPersona = PolizaD.IdPersona
    INNER JOIN dbo.tCNTdivisiones Division WITH ( NOLOCK ) ON Division.IdDivision = PolizaD.IdDivision
    INNER JOIN dbo.tSDOtransaccionesFinancieras TransaccionFinanciera WITH ( NOLOCK ) ON TransaccionFinanciera.IdTransaccion = PolizaD.IdTransaccionFinanciera
    INNER JOIN dbo.tGRLoperacionesD OperacionD WITH ( NOLOCK ) ON OperacionD.IdOperacionD = PolizaD.IdOperacionDOrigen
    INNER JOIN dbo.tCTLsucursales Sucursal WITH ( NOLOCK ) ON Sucursal.IdSucursal = PolizaD.IdSucursal
    INNER JOIN dbo.tIMPimpuestos ImpuestoOperacionD WITH ( NOLOCK ) ON ImpuestoOperacionD.IdImpuesto = OperacionD.IdImpuesto
    INNER JOIN dbo.tIMPimpuestos ImpuestoTransaccionFinanciera WITH ( NOLOCK ) ON ImpuestoTransaccionFinanciera.IdImpuesto = TransaccionFinanciera.IdImpuesto
    INNER JOIN dbo.tGRLbienesServicios BienServicio WITH ( NOLOCK ) ON BienServicio.IdBienServicio = PolizaD.IdBienServicio
    WHERE Poliza.IdPeriodo = @IdPeriodo AND Poliza.IdEstatus = 1 AND (( AsientoD.Campo IN ('InteresMoratorioPagado', 'InteresMoratorioPagadoVencido', 'InteresOrdinarioPagado', 'InteresOrdinarioPagadoVencido') AND AsientoD.IdTipoDDominio = 143 ) OR ( AsientoD.IdTipoDRubro = 2726 OR AsientoD.Campo IN ('Subtotal') AND AsientoD.IdTipoOperacion = 17 ));
END;
GO


/**/

IF NOT EXISTS ( SELECT 1
                FROM sys.columns c
                WHERE c.name = 'IdTransaccionImpuesto' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD IdTransaccionImpuesto INT NOT NULL DEFAULT 0;
END;

IF NOT EXISTS ( SELECT 1 FROM sys.columns c WHERE c.name = 'BaseIVA' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD BaseIVA NUMERIC(18, 2) NULL;
END;

IF NOT EXISTS ( SELECT 1 FROM sys.columns c WHERE c.name = 'IVA' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD IVA NUMERIC(18, 2) NULL;
END;

IF NOT EXISTS ( SELECT 1 FROM sys.columns c WHERE c.name = 'TasaIVA' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD TasaIVA NUMERIC(18, 2) NULL;
END;

IF NOT EXISTS ( SELECT 1
                FROM sys.columns c
                WHERE c.name = 'TasaRetencionIVA' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD TasaRetencionIVA NUMERIC(18, 2) NULL;
END;

IF NOT EXISTS ( SELECT 1
                FROM sys.columns c
                WHERE c.name = 'TasaRetencionISR' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD TasaRetencionISR NUMERIC(18, 2) NULL;
END;

IF NOT EXISTS ( SELECT 1 FROM sys.columns c WHERE c.name = 'IdImpuesto' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD IdImpuesto INT NOT NULL DEFAULT 0;
END;

IF NOT EXISTS ( SELECT 1
                FROM sys.columns c
                WHERE c.name = 'IdOperacionCuentasOrden' AND c.object_id = OBJECT_ID ('tCNTpolizasD'))
BEGIN
    ALTER TABLE dbo.tCNTpolizasD
    ADD IdOperacionCuentasOrden INT NOT NULL DEFAULT 0;
END;

IF NOT EXISTS ( SELECT IdTipoD FROM dbo.tCTLtiposD WHERE IdTipoD = 2725 )
    INSERT INTO dbo.tCTLtiposD ( IdTipoD, Codigo, Descripcion, DescripcionLarga, IdTipoE, IdTipoDPadre, RangoInicio, RangoFin, PermiteHistorial, PermiteCambios, TipoDivisaDivision, UsaEstructuraCatalogo, IdEstatus, IdTipoDestatus, IdEstatusPrincipal, IdCuentaABCDacreedor, UsaEstructuraContable, Valor, Naturaleza, Factor, Orden, ValorSimple, IdCatalogoSITI, Valor5C )
    VALUES ( 2725, 'ICCARGO', 'INGRESO COBRADO (CARGO)', 'INGRESO COBRADO (CARGO)', 12, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0.00000000, 0, 0, 0, 0.00000000, 0, 0.00 );

IF NOT EXISTS ( SELECT IdTipoD FROM dbo.tCTLtiposD WHERE IdTipoD = 2726 )
    INSERT INTO dbo.tCTLtiposD ( IdTipoD, Codigo, Descripcion, DescripcionLarga, IdTipoE, IdTipoDPadre, RangoInicio, RangoFin, PermiteHistorial, PermiteCambios, TipoDivisaDivision, UsaEstructuraCatalogo, IdEstatus, IdTipoDestatus, IdEstatusPrincipal, IdCuentaABCDacreedor, UsaEstructuraContable, Valor, Naturaleza, Factor, Orden, ValorSimple, IdCatalogoSITI, Valor5C )
    VALUES ( 2726, 'ICABONO', 'INGRESO COBRADO (ABONO)', 'INGRESO COBRADO (ABONO)', 12, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0.00000000, 0, 0, 0, 0.00000000, 0, 0.00 );

IF NOT EXISTS ( SELECT IdTipoD FROM dbo.tCTLtiposD WHERE IdTipoD = 2727 )
    INSERT INTO dbo.tCTLtiposD ( IdTipoD, Codigo, Descripcion, DescripcionLarga, IdTipoE, IdTipoDPadre, RangoInicio, RangoFin, PermiteHistorial, PermiteCambios, TipoDivisaDivision, UsaEstructuraCatalogo, IdEstatus, IdTipoDestatus, IdEstatusPrincipal, IdCuentaABCDacreedor, UsaEstructuraContable, Valor, Naturaleza, Factor, Orden, ValorSimple, IdCatalogoSITI, Valor5C )
    VALUES ( 2727, 'GPCARGO', 'GASTO PAGADO (CARGO)', 'GASTO PAGADO (CARGO)', 12, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0.00000000, 0, 0, 0, 0.00000000, 0, 0.00 );

IF NOT EXISTS ( SELECT IdTipoD FROM dbo.tCTLtiposD WHERE IdTipoD = 2728 )
    INSERT INTO dbo.tCTLtiposD ( IdTipoD, Codigo, Descripcion, DescripcionLarga, IdTipoE, IdTipoDPadre, RangoInicio, RangoFin, PermiteHistorial, PermiteCambios, TipoDivisaDivision, UsaEstructuraCatalogo, IdEstatus, IdTipoDestatus, IdEstatusPrincipal, IdCuentaABCDacreedor, UsaEstructuraContable, Valor, Naturaleza, Factor, Orden, ValorSimple, IdCatalogoSITI, Valor5C )
    VALUES ( 2728, 'GPABONO', 'GASTO PAGADO (ABONO)', 'GASTO PAGADO (ABONO)', 12, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0.00000000, 0, 0, 0, 0.00000000, 0, 0.00 );

IF NOT EXISTS ( SELECT IdTipoOperacion FROM dbo.tCTLtiposOperacion WHERE IdTipoOperacion = 538 )
    INSERT INTO dbo.tCTLtiposOperacion ( IdTipoOperacion, IdTipoDdominio, Codigo, Descripcion, DescripcionLarga, UsaSeries, IdAsiento, IdListaDpoliza, IdAgrupadorSaldo, IdEstatus, AplicaMovimientoIntersucursal, IdAuxiliar, AfectarAuxiliarRetenciones, EsOperacionUsuario, SerieDefault, Naturaleza, NaturalezaInventario, IdTipoDingresoGasto )
    VALUES ( 538, 0, 'INGCOB', 'INGRESO COBRADO', 'INGRESO COBRADO', 0, 0, 0, 0, 1, 0, 0, 0, 0, '', -1, 0, 0 );

IF NOT EXISTS ( SELECT IdTipoOperacion FROM dbo.tCTLtiposOperacion WHERE IdTipoOperacion = 539 )
    INSERT INTO dbo.tCTLtiposOperacion ( IdTipoOperacion, IdTipoDdominio, Codigo, Descripcion, DescripcionLarga, UsaSeries, IdAsiento, IdListaDpoliza, IdAgrupadorSaldo, IdEstatus, AplicaMovimientoIntersucursal, IdAuxiliar, AfectarAuxiliarRetenciones, EsOperacionUsuario, SerieDefault, Naturaleza, NaturalezaInventario, IdTipoDingresoGasto )
    VALUES ( 539, 0, 'GASPA', 'GASTO PAGADO', 'GASTO PAGADO', 0, 0, 0, 0, 1, 0, 0, 0, 0, '', 1, 0, 0 );

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 139 AND IdTipoDRubro = 2725 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 139, 2725, 0, 1, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 139 AND IdTipoDRubro = 2726 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 139, 2726, 0, 1, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 141 AND IdTipoDRubro = 2725 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 141, 2725, 0, 8, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 141 AND IdTipoDRubro = 2726 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 141, 2726, 0, 8, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 142 AND IdTipoDRubro = 2725 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 142, 2725, 0, 1, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 142 AND IdTipoDRubro = 2726 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 142, 2726, 0, 1, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2249 AND IdTipoDRubro = 2725 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2249, 2725, 0, 2, 2, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2249 AND IdTipoDRubro = 2726 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2249, 2726, 0, 2, 2, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2637 AND IdTipoDRubro = 2725 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2637, 2725, 0, 1, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2637 AND IdTipoDRubro = 2726 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2637, 2726, 0, 1, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 139 AND IdTipoDRubro = 2727 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 139, 2727, 0, 10, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 139 AND IdTipoDRubro = 2728 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 139, 2728, 0, 10, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 142 AND IdTipoDRubro = 2727 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 142, 2727, 0, 8, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 142 AND IdTipoDRubro = 2728 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 142, 2728, 0, 8, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 1575 AND IdTipoDRubro = 2727 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 1575, 2727, 0, 5, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 1575 AND IdTipoDRubro = 2728 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 1575, 2728, 0, 5, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2248 AND IdTipoDRubro = 2727 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2248, 2727, 0, 2, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2248 AND IdTipoDRubro = 2728 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2248, 2728, 0, 2, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2249 AND IdTipoDRubro = 2727 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2249, 2727, 0, 2, 2, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2249 AND IdTipoDRubro = 2728 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2249, 2728, 0, 2, 2, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2637 AND IdTipoDRubro = 2727 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2637, 2727, 0, 10, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdDominioRubro FROM dbo.tCTLdominiosRubros WHERE IdTipoDDominio = 2637 AND IdTipoDRubro = 2728 )
BEGIN
    INSERT INTO dbo.tCTLdominiosRubros ( IdTipoDDominio, IdTipoDRubro, IdTipoDCuentaContable, Orden, IdEstatus, IdTipoDCuentaContablePadre, IdTipoDCuentaContableGrupo, IdAuxiliar, Grupo )
    VALUES ( 2637, 2728, 0, 10, 1, 0, 0, 0, '4. Cuentas de orden' );
END;

IF NOT EXISTS ( SELECT IdAsientoD
                FROM dbo.tCNTasientosD
                WHERE IdTipoDDominio = 141 AND IdTipoDRubro = 2725 AND IdTipoOperacion = 538 )
BEGIN
    INSERT INTO dbo.tCNTasientosD ( IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias )
    VALUES ( 1, 1, 3, 141, 2725, 'CuentaOrden', 'Valor', 1, 0, 0, 538, 0, 1, 0, 'Valor' );
END;

IF NOT EXISTS ( SELECT IdAsientoD
                FROM dbo.tCNTasientosD
                WHERE IdTipoDDominio = 141 AND IdTipoDRubro = 2726 AND IdTipoOperacion = 538 )
BEGIN
    INSERT INTO dbo.tCNTasientosD ( IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias )
    VALUES ( 1, 1, 3, 141, 2726, 'CuentaOrden', 'Valor', 0, 0, 0, 538, 0, 1, 0, 'Valor' );
END;

IF NOT EXISTS ( SELECT IdAsientoD
                FROM dbo.tCNTasientosD
                WHERE IdTipoDDominio = 1575 AND IdTipoDRubro = 2727 AND IdTipoOperacion = 539 )
BEGIN
    INSERT INTO dbo.tCNTasientosD ( IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias )
    VALUES ( 1, 1, 3, 1575, 2727, 'CuentaOrden', 'Valor', 1, 0, 0, 539, 0, 1, 0, 'Valor' );
END;

IF NOT EXISTS ( SELECT IdAsientoD
                FROM dbo.tCNTasientosD
                WHERE IdTipoDDominio = 1575 AND IdTipoDRubro = 2728 AND IdTipoOperacion = 539 )
BEGIN
    INSERT INTO dbo.tCNTasientosD ( IdAsiento, Partida, GrupoPartidas, IdTipoDDominio, IdTipoDRubro, Origen, Campo, EsCargo, EsDivisaLocal, IdTipoDDominioSubOperacion, IdTipoOperacion, EsImpuestos, IdEstatus, IdEstatusDominio, CampoAlias )
    VALUES ( 1, 1, 3, 1575, 2728, 'CuentaOrden', 'Valor', 0, 0, 0, 539, 0, 1, 0, 'Valor' );
END;

UPDATE Asiento
SET Asiento.Origen = 'CuentaOrden',
    Asiento.Campo = 'Valor',
    Asiento.CampoAlias = 'Valor'
FROM dbo.tCNTasientosD Asiento
WHERE IdTipoOperacion IN (538, 539);

