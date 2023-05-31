/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/06/2020
=============================================*/
IF EXISTS (SELECT object_id
           FROM sys.views
           WHERE object_id = OBJECT_ID('vNOMoperacionNominaPadreBase'))
    DROP VIEW dbo.vNOMoperacionNominaPadreBase ;
GO
CREATE VIEW dbo.vNOMoperacionNominaPadreBase
AS
--Crea la operacion padre
SELECT IdRecurso = 420,
       Serie = '',
       Folio,
       IdTipoOperacion = 18,
       fecha = FechaPago,
       Concepto,
       IdPeriodo = dbo.fGETidPeriodo(FechaPago),
       Nomina.IdSucursal,
       Referencia = CONCAT(IdNomina, ''),
       IdDivisa,
       FactorDivisa,
       IdEstatus,
       IdUsuarioAlta,
       Alta = GETDATE(),
       IdTipoDdominio = 1467,
       IdSesion,
       RequierePoliza = 1,
       TienePoliza = 0,
       IdListaDPoliza = -1,
       Nomina.IdNomina,
       NominaIdEstatus = Nomina.IdEstatus
FROM dbo.tNOMnominas Nomina WITH (NOLOCK)
WHERE Nomina.IdNomina > 0 AND Nomina.IdEstatus = 1 ;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/06/2020
=============================================*/
IF EXISTS (SELECT object_id
           FROM sys.views
           WHERE object_id = OBJECT_ID('vNOMoperacionNominaEmpleadosBase'))
    DROP VIEW dbo.vNOMoperacionNominaEmpleadosBase ;
GO
CREATE VIEW dbo.vNOMoperacionNominaEmpleadosBase
AS
SELECT Operacion.IdRecurso,
       Operacion.Serie,
       Folio = NominaEmpleado.IdNominaEmpleado,
       IdTipoOperacion = 20,
       Operacion.Fecha,
       Concepto = 'PAGO DE NÓMINA',
       Referencia = Empleado.Codigo,
       IdPersona = Empleado.IdPersonaFisica,
       Operacion.IdPeriodo,
       Empleado.IdSucursal,
       Operacion.IdDivisa,
       Operacion.FactorDivisa,
       RelOperaciones = 0,
       RelOperacionesD = 0,
       RelTransacciones = 0,
       IdCuentaABCD = Persona.IdCuentaABCDdeudorAcreedor,
       Operacion.TienePoliza,
       Operacion.IdListaDPoliza,
       IdEstatus = 1,
       Operacion.IdUsuarioAlta,
       Alta = GETDATE(),
       IdTipoDdominio = 1497,
       Operacion.IdSesion,
       Operacion.RequierePoliza,
       IdOperacionPadre = Operacion.IdOperacion,
       AltaLocal = GETDATE(),
       Nomina.IdNomina,
       NominaIdEstatus = Nomina.IdEstatus
FROM dbo.tNOMnominasEmpleados NominaEmpleado WITH (NOLOCK)
INNER JOIN dbo.tNOMnominas Nomina WITH (NOLOCK) ON Nomina.IdNomina = NominaEmpleado.IdNomina
INNER JOIN dbo.tPERempleados Empleado WITH (NOLOCK) ON Empleado.IdEmpleado = NominaEmpleado.IdEmpleado
INNER JOIN dbo.tGRLpersonas Persona WITH (NOLOCK) ON Persona.IdPersonaFisica = Empleado.IdPersonaFisica
INNER JOIN dbo.tGRLoperaciones Operacion WITH (NOLOCK) ON Operacion.IdOperacion = Nomina.IdOperacion
WHERE Operacion.IdOperacion > 0 AND Nomina.IdEstatus = 1 ;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/06/2020
=============================================*/
IF EXISTS (SELECT object_id
           FROM sys.views
           WHERE object_id = OBJECT_ID('vNOMoperacionNominaEmpleadosTransaccionesBase'))
    DROP VIEW dbo.vNOMoperacionNominaEmpleadosTransaccionesBase ;
GO
CREATE VIEW dbo.vNOMoperacionNominaEmpleadosTransaccionesBase
AS
SELECT NominaEmpleado.IdOperacion,
       IdTipoSubOperacion = CASE WHEN BienServicio.IdTipoDaplicacion = -1524 THEN 513
                                 WHEN BienServicio.IdTipoDaplicacion = 1522 THEN 513
                                 WHEN BienServicio.IdTipoDaplicacion = 1523 THEN 502 -- deposito
                                 WHEN BienServicio.IdTipoDaplicacion = 1586 THEN 502 -- deposito
                                 WHEN BienServicio.IdTipoDaplicacion = 2662 THEN 502 -- APLICA SALDO DEUDOR 
                                 WHEN BienServicio.IdTipoDaplicacion = 1576 THEN 516
                                 ELSE 0
                            END,
       Nomina.Fecha,
       Descripcion = CASE WHEN BienServicio.IdTipoDaplicacion = -1524 THEN 'PROVISIÓN'
                          WHEN BienServicio.IdTipoDaplicacion = 1522 THEN 'PROVISIÓN'
                          WHEN BienServicio.IdTipoDaplicacion = 1576 THEN 'PROVISIÓN SALDO DEUDOR'
                          WHEN BienServicio.IdTipoDaplicacion = 1576 THEN 'APLICACIÓN SALDO DEUDOR'
                          WHEN BienServicio.IdTipoDaplicacion = 1523 THEN 'APLICACIÓN'
                          WHEN BienServicio.IdTipoDaplicacion = 1586 THEN 'APLICACIÓN'
                          ELSE ''
                     END,
       IdSaldoDestino = d.IdSaldo,
       IdTipoDDominioDestino = Saldo.IdTipoDDominioCatalogo,
       d.IdAuxiliar,
       d.IdBienServicio,
       IdDivisa = 1,
       FactorDivisa = 1,
       Naturaleza = CASE WHEN BienServicio.IdTipoDaplicacion = 1523 THEN -1
                         WHEN BienServicio.IdTipoDaplicacion = 1586 THEN -1
                         ELSE 1
                    END,
       MontoSubOperacion = d.Total,
       TotalCargos = IIF(BienServicio.IdTipoDaplicacion IN (1523, 1586, 2662), 0, d.Total),
       TotalAbonos = IIF(BienServicio.IdTipoDaplicacion IN (1523, 1586, 2662), d.Total, 0),
       CambioNeto = IIF(BienServicio.IdTipoDaplicacion IN (1523, 1586, 2662), d.Total * -1, d.Total),
       SubTotalGenerado = IIF(BienServicio.IdTipoDaplicacion IN (1523, 1586, 2662), 0, d.Total),
       SubTotalPagado = IIF(BienServicio.IdTipoDaplicacion IN (1523, 1586, 2662), d.Total, 0),
       Concepto = BienServicio.Descripcion,
       Referencia = Empleado.Codigo,
       Empleado.IdSucursal,
       IdEstructuraContableE = Saldo.IdEstructuraContable,
       Sucursal.IdCentroCostos,
       IdEstatus = 1,
       IdUsuarioAlta = -1,
       Alta = GETDATE(),
       IdSesion = 0,
       Saldo = Saldo.Saldo + d.Total,
       SaldoAnterior = Saldo.Saldo,
       Nomina.IdNomina,
       d.IdNominaPercepcionDeduccion,
       BienServicio.IdTipoDaplicacion,
       Empleado.IdEmpleado,
       IdPersona = Empleado.IdPersonaFisica,
       Orden = CASE WHEN BienServicio.IdTipoDaplicacion = -1524 THEN 3
                    WHEN BienServicio.EsPercepcion = 1 THEN 1
                    WHEN BienServicio.EsPercepcion = 0 THEN 2
                    ELSE 4
               END
FROM (SELECT IdNominaPercepcionDeduccion,
             RelNominaEmpleado,
             IdSaldo,
             IdBienServicio,
             IdAuxiliar,
             Total = ABS(ImporteGravado + ImporteExento + Otros)
      FROM dbo.tNOMnominasPercepcionesDeducciones WITH (NOLOCK)) AS d
INNER JOIN dbo.tSDOsaldos Saldo WITH (NOLOCK) ON Saldo.IdSaldo = d.IdSaldo
INNER JOIN dbo.tNOMnominasEmpleados NominaEmpleado WITH (NOLOCK) ON NominaEmpleado.IdNominaEmpleado = d.RelNominaEmpleado
INNER JOIN dbo.tNOMnominas Nomina WITH (NOLOCK) ON Nomina.IdNomina = NominaEmpleado.IdNomina
INNER JOIN dbo.tPERempleados Empleado WITH (NOLOCK) ON Empleado.IdEmpleado = NominaEmpleado.IdEmpleado
INNER JOIN dbo.tCTLsucursales Sucursal WITH (NOLOCK) ON Sucursal.IdSucursal = Empleado.IdSucursal
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = d.IdBienServicio
INNER JOIN dbo.tGRLestructurasCatalogos ecat WITH (NOLOCK) ON ecat.IdEstructuraCatalogo = BienServicio.IdEstructuraCatalogo
WHERE Nomina.IdEstatus <> 18 AND Nomina.IdNomina > 0 AND BienServicio.IdTipoDaplicacion IN (-1524, 1522, 1523, 1586, 1576, 2662) AND NOT Saldo.IdEstatus IN (7, 18) ;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/06/2020
=============================================*/
IF EXISTS (SELECT object_id
           FROM sys.views
           WHERE object_id = OBJECT_ID('vNOMoperacionNominaEmpleadosProvisionSueldos'))
    DROP VIEW dbo.vNOMoperacionNominaEmpleadosProvisionSueldos ;
GO
CREATE VIEW dbo.vNOMoperacionNominaEmpleadosProvisionSueldos
AS
SELECT NominaEmpleado.IdOperacion,
       IdTipoSubOperacion = 500,
       Nomina.Fecha,
       Descripcion = UPPER(LTRIM(RTRIM(Persona.Nombre))),
       IdSaldoDestino = Saldo.IdSaldo,
       IdTipoDDominioDestino = Saldo.IdTipoDDominioCatalogo,
       IdAuxiliar = Saldo.IdAuxiliar,
       Saldo.IdDivisa,
       FactorDivisa = 1,
       Saldo.Naturaleza,
       MontoSubOperacion = ReciboNomina.Total,
       TotalCargos = ReciboNomina.Total,
       CambioNeto = ReciboNomina.Total,
       SubTotalGenerado = ReciboNomina.Total,
       Concepto = CONCAT('PAGO DE NÓMINA ', CONVERT(VARCHAR(18), Nomina.Fecha, 103)),
       Referencia = Empleado.Codigo,
       Empleado.IdSucursal,
       IdEstructuraContableE = Saldo.IdEstructuraContable,
       Sucursal.IdCentroCostos,
       IdEstatus = 1,
       IdUsuarioAlta = 0,
       Alta = GETDATE(),
       IdSesion = 0,
       Saldo = Saldo.Saldo + ReciboNomina.Total,
       SaldoAnterior = Saldo.Saldo,
       Nomina.IdNomina,
       Mensaje = IIF(Saldo.IdSaldo IS NULL, 'ERROR', ''),
       NominaEmpleado.IdEmpleado,
       IdPersona = Empleado.IdPersonaFisica,
       Empleado.IdAuxiliarSueldo
FROM (SELECT RelNominaEmpleado,
             Total
      FROM dbo.vNOMpercepcionDeduccionesTotales) AS ReciboNomina
JOIN dbo.tNOMnominasEmpleados NominaEmpleado WITH (NOLOCK) ON NominaEmpleado.IdNominaEmpleado = ReciboNomina.RelNominaEmpleado
JOIN dbo.tNOMnominas Nomina WITH (NOLOCK) ON Nomina.IdNomina = NominaEmpleado.IdNomina
JOIN dbo.tPERempleados Empleado WITH (NOLOCK) ON Empleado.IdEmpleado = NominaEmpleado.IdEmpleado
JOIN dbo.tGRLpersonas Persona WITH (NOLOCK) ON Persona.IdPersona = Empleado.IdPersonaFisica
JOIN dbo.tCTLsucursales Sucursal WITH (NOLOCK) ON Sucursal.IdSucursal = Empleado.IdSucursal
LEFT JOIN (SELECT Saldo.IdSaldo,
                  Saldo.IdPersona,
                  Saldo.IdAuxiliar,
                  Saldo.IdEstructuraContable,
                  Saldo.IdTipoDDominioCatalogo,
                  Saldo.Saldo,
                  Saldo.Naturaleza,
                  Saldo.IdDivisa
           FROM dbo.tSDOsaldos Saldo WITH (NOLOCK)
           -- auxiliar de sueldos
           INNER JOIN dbo.tCNTauxiliares Auxiliar WITH (NOLOCK) ON Auxiliar.IdAuxiliar = Saldo.IdAuxiliar
           WHERE Saldo.IdCuenta = 0 AND Auxiliar.PermiteNomina = 1 AND Saldo.IdEstatus = 1 AND Saldo.IdDivisa = 1 AND Saldo.Naturaleza = -1) AS Saldo ON Saldo.IdPersona = Empleado.IdPersonaFisica
WHERE Nomina.IdNomina > 0 AND Nomina.IdEstatus = 1 ;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/06/2020
=============================================*/
IF EXISTS (SELECT object_id
           FROM sys.views
           WHERE object_id = OBJECT_ID('vNOMoperacionNominaEmpleadosOperacionesDBase'))
    DROP VIEW dbo.vNOMoperacionNominaEmpleadosOperacionesDBase ;
GO
CREATE VIEW dbo.vNOMoperacionNominaEmpleadosOperacionesDBase
AS
SELECT RelOperacionD = NominaEmpleado.IdOperacion,
       IdTipoSubOperacion = 18,
       IdTipoDDominioDestino = BienServicio.IdTipoD,
       BienServicio.IdBienServicio,
       BienServicio.IdDivision,
       Concepto = SUBSTRING(BienServicio.Descripcion, 1, 30),
       Referencia = Empleado.Codigo,
       Empleado.IdSucursal,
       Sucursal.IdCentroCostos,
       EstructuraContable.IdEstructuraContableE,
       ImporteGravado = IIF(BienServicio.EsPercepcion = 1, PercepcionDeduccion.ImporteGravado, 0),
       -- Cuando son obligaciones -1524 vamos hacer la contrapartida
       ImporteExento = CASE WHEN BienServicio.EsPercepcion = 1 AND BienServicio.IdTipoDaplicacion IN (1524) THEN PercepcionDeduccion.ImporteExento
                            WHEN BienServicio.IdTipoDaplicacion IN (-1524) THEN PercepcionDeduccion.Otros
                            ELSE 0
                       END,
       ImporteDeduccionGravado = IIF(BienServicio.EsPercepcion = 0, PercepcionDeduccion.ImporteGravado, 0),
       ImporteDeduccionExento = CASE WHEN BienServicio.EsPercepcion = 0 AND BienServicio.IdTipoDaplicacion IN (1524) THEN PercepcionDeduccion.ImporteExento
                                     ELSE 0
                                END,
       Total = (PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento + PercepcionDeduccion.Otros),
       IdEstatus = 1,
       IdUsuarioAlta = 0,
       Alta = GETDATE(),
       IdTipoDdominio = 761,
       IdSesion = 0,
       IdEstatusDominio = 1,
       NominaEmpleado.IdNomina,
       NominaIdEstatus = Nomina.IdEstatus,
       Orden = CASE WHEN BienServicio.IdTipoDaplicacion = 1524 AND BienServicio.EsPercepcion = 1 THEN 1
                    WHEN BienServicio.IdTipoDaplicacion = 1524 AND BienServicio.EsPercepcion = 0 THEN 2
                    WHEN BienServicio.IdTipoDaplicacion = -1524 THEN 3
                    ELSE 4
               END,
       BienServicio = BienServicio.Codigo
FROM dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion WITH (NOLOCK)
INNER JOIN dbo.tNOMnominasEmpleados NominaEmpleado WITH (NOLOCK) ON NominaEmpleado.IdNominaEmpleado = PercepcionDeduccion.RelNominaEmpleado
INNER JOIN dbo.tNOMnominas Nomina ON Nomina.IdNomina = NominaEmpleado.IdNomina
INNER JOIN dbo.tPERempleados Empleado WITH (NOLOCK) ON Empleado.IdEmpleado = NominaEmpleado.IdEmpleado
INNER JOIN dbo.tCTLsucursales Sucursal WITH (NOLOCK) ON Sucursal.IdSucursal = Empleado.IdSucursal
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = PercepcionDeduccion.IdBienServicio
INNER JOIN dbo.tGRLestructurasCatalogos EstructuraContable WITH (NOLOCK) ON EstructuraContable.IdEstructuraCatalogo = BienServicio.IdEstructuraCatalogo
WHERE NominaEmpleado.IdNomina > 0 AND BienServicio.IdTipoDaplicacion IN (1524, -1524) AND Nomina.IdEstatus = 1 ;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  29/06/2020
=============================================*/
IF EXISTS (SELECT object_id
           FROM sys.views
           WHERE object_id = OBJECT_ID('vNOMpercepcionDeduccionesTotales'))
    DROP VIEW dbo.vNOMpercepcionDeduccionesTotales ;
GO
CREATE VIEW [dbo].[vNOMpercepcionDeduccionesTotales]
AS
SELECT PercepcionDeduccion.RelNominaEmpleado,
       PercepcionDeduccion.IdEmpleado,
       PercepcionDeduccion.IdNomina,
       TotalPercepciones = SUM(CASE WHEN BienServicio.EsPercepcion = 1 THEN PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                    ELSE 0
                               END),
       TotalDeducciones = SUM(CASE WHEN BienServicio.EsPercepcion = 0 THEN PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                   ELSE 0
                              END),
       Total = SUM((CASE WHEN BienServicio.EsPercepcion = 1 THEN PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                         ELSE 0
                    END) - (CASE WHEN BienServicio.EsPercepcion = 0 THEN PercepcionDeduccion.ImporteGravado + PercepcionDeduccion.ImporteExento
                                 ELSE 0
                            END))
FROM dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion WITH (NOLOCK)
INNER JOIN dbo.tGRLbienesServicios BienServicio WITH (NOLOCK) ON BienServicio.IdBienServicio = PercepcionDeduccion.IdBienServicio
INNER JOIN dbo.tCTLestatusActual EstatusBien WITH (NOLOCK) ON EstatusBien.IdEstatusActual = BienServicio.IdEstatusActual
-- omitimos las obligaciones y el deposito de prestamos, viatico y anticipos 
WHERE NOT BienServicio.IdTipoDaplicacion IN (-1523, -1524) AND PercepcionDeduccion.IdNominaPercepcionDeduccion > 0 AND EstatusBien.IdEstatus = 1
GROUP BY PercepcionDeduccion.RelNominaEmpleado,
         PercepcionDeduccion.IdEmpleado,
         PercepcionDeduccion.IdNomina ;
GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  06/07/2020
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pNOMImportarCalculosNominaEmpleados'))
DROP PROCEDURE pNOMImportarCalculosNominaEmpleados
GO

CREATE PROC [dbo].[pNOMImportarCalculosNominaEmpleados]
AS
BEGIN
    DECLARE @PeriodoNomina VARCHAR(25) = '' ;
    DECLARE @ExcluirObligaciones BIT = 0 ;
    DECLARE @FechaPago DATE = '19000101' ;
    DECLARE @IdTipoNomina INT = 0 ;
    DECLARE @IdSucursal INT = 0 ;

    SELECT TOP(1)@PeriodoNomina = Periodo,
                 @ExcluirObligaciones = ExcluirObligaciones,
                 @FechaPago = FechaPago,
                 @IdTipoNomina = IdTipoNomina,
                 @IdSucursal = IdSucursal
    FROM ##PercepcionesDeducciones
    WHERE Periodo IS NOT NULL
    ORDER BY id ;
    /*===================================================================
								1.-	CREA EL CALCULO DE NÓMINA
	 ===================================================================  */
    INSERT INTO dbo.tNOMcalculosE(IdEmpresa, IdRegistroPatronal, IdTipoNomina, IdPeriodoNomina, IdTipoDnomina, IdTipoDaplicacion, IdEmpleado, IdSucursal, IdProducto, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdObservacionEDominio, IdSesion)
    SELECT IdEmpresa = 1,
           TipoNomina.IdRegistroPatronal,
           TipoNomina.IdTipoNomina,
           Periodo.IdPeriodoNomina,
           IdTipoDnomina = 1952,
           0,
           0,
           0,
           0,
           IdEstatus = 1,
           0,
           GETDATE(),
           0,
           GETDATE(),
           0,
           0
    FROM dbo.tNOMtiposNominas TipoNomina
    INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdTipoNomina = TipoNomina.IdTipoNomina AND Periodo.Codigo = @PeriodoNomina
    WHERE TipoNomina.IdTipoNomina = @IdTipoNomina AND TipoNomina.IdEstatus = 1 AND NOT EXISTS (SELECT 1
                                                                                               FROM dbo.tNOMcalculosE Calculo WITH(NOLOCK)
                                                                                               WHERE Calculo.IdTipoNomina = TipoNomina.IdTipoNomina AND Calculo.IdPeriodoNomina = Periodo.IdPeriodoNomina AND Calculo.IdEstatus = 1) AND TipoNomina.IdRegistroPatronal <> 0 ;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.tNOMtiposNominas TipoNomina WITH(NOLOCK)
                   INNER JOIN dbo.tNOMperiodos Periodo WITH(NOLOCK)ON Periodo.IdTipoNomina = TipoNomina.IdTipoNomina AND Periodo.Codigo = @PeriodoNomina
                   WHERE TipoNomina.IdEstatus = 1)
    BEGIN
        SELECT IdEstatus = 39, [Información] = 'FALTA EL CÁLCULO' ;
        RETURN 0 ;
    END ;


    IF @ExcluirObligaciones = 1
    BEGIN
        DELETE FROM ##PercepcionesDeducciones
        WHERE Concepto IN ('98', '97', '96', '93', '90', '89', '134', '178', '105', '107') ;
    END ;

    DELETE 
	FROM ##PercepcionesDeducciones 
	WHERE Concepto = 'P014' ; -- VALES DE DESPENSA

    /*==================================================================
		2.- SE ALMACENAN LOS REGISTROS DEL LAYOUT EN LA TABLA DE APOYO.						
	===================================================================*/
    IF OBJECT_ID(N'#Nomina', N'U') IS NOT NULL
        DROP TABLE #Nomina ;

    SELECT Id,
           Empleado = IIF(Empleado IS NULL, NULL, Empleado),
           Concepto = UPPER(Concepto),
           Descripcion = UPPER(F3),
           Dias = Percepciones,
           PGravada = [Perc# Gravada],
           PExenta = [Perc# Exenta],
           POtros = [Perc# Otros],
           Deduccion = Deducciones,
           Obligacion = Obligaciones,
           Tipo = CASE WHEN (ISNULL([Perc# Gravada], 0) + ISNULL([Perc# Exenta], 0)) <> 0 THEN 1
                       WHEN Deducciones <> 0 THEN 2
                       WHEN Obligaciones <> 0 THEN 3
                       WHEN [Perc# Otros] <> 0 THEN 4
                       ELSE 0
                  END,
           IdEmpleado = 0,
           IdBienServicio = 0,
           MontoGravado = 0.00,
           MontoExento = 0.00,
           Periodo
    INTO #Nomina
    FROM ##PercepcionesDeducciones
    WHERE NOT [F3] IS NULL
    ORDER BY Id ;

    UPDATE #Nomina
    SET Concepto = '99D'
    WHERE Concepto = '99' AND Descripcion = 'Fomento a la Educacion' ;

    DECLARE Foreach CURSOR LOCAL READ_ONLY FORWARD_ONLY FOR
    SELECT Empleado,
           Concepto,
           Descripcion,
           Dias,
           PGravada,
           PExenta = (ISNULL(PExenta, 0) + ISNULL(Deduccion, 0)),
           Otros = (ISNULL(POtros, 0) + ISNULL(Obligacion, 0)),
           Tipo,
           Periodo
    FROM #Nomina
    ORDER BY Id ;

    DECLARE @IdEmpleado     INT,
            @Empleado       VARCHAR(250),
            @CodigoEmpleado VARCHAR(250),
            @Nombre         VARCHAR(MAX),
            @NombreEmpleado VARCHAR(MAX),
            @Tipo           INT,
            @Concepto       VARCHAR(MAX),
            @Gravado        NUMERIC(28, 3),
            @Exento         NUMERIC(28, 3),
            @Otros          NUMERIC(28, 3),
            @Dias           NUMERIC(18, 2),
            @DiasX          NUMERIC(18, 2),
            @IdPeriodo      INT,
            @CodigoPeriodo  VARCHAR(20) ;

    IF OBJECT_ID(N'#Tabla', N'U') IS NOT NULL
        DROP TABLE #Tabla ;

    CREATE TABLE #Tabla
    (
        IdPeriodo INT NULL,
        IdEmpleado INT NULL,
        Dias NUMERIC(18, 2) NULL,
        Empleado VARCHAR(250) NULL,
        Nombre VARCHAR(MAX) NULL,
        IdBienServicio INT NULL,
        Codigo VARCHAR(MAX) NULL,
        Concepto VARCHAR(MAX) NULL,
        Gravado NUMERIC(28, 3) NULL,
        Exento NUMERIC(28, 3) NULL,
        Otros NUMERIC(28, 2) NULL,
        Tipo INT NULL
    ) ;

    OPEN Foreach ;

    FETCH NEXT FROM Foreach
    INTO @Empleado,
         @Concepto,
         @Nombre,
         @Dias,
         @Gravado,
         @Exento,
         @Otros,
         @Tipo,
         @CodigoPeriodo ;

    WHILE @@Fetch_Status = 0
    BEGIN
        IF(LEN(@Empleado) > 0)
        BEGIN
            SELECT @IdEmpleado = ISNULL(b.IdEmpleado, 0),
                   @CodigoEmpleado = b.Codigo,
                   @NombreEmpleado = b.Nombre,
                   @IdTipoNomina = b.IdTipoNomina,
                   @DiasX = @Dias
            FROM dbo.vPERempleados b
            WHERE Codigo = @Empleado ;


        END ;
        ELSE
        BEGIN
            SELECT @IdPeriodo = IdPeriodoNomina
            FROM dbo.tNOMperiodos WITH(NOLOCK)
            WHERE IdTipoNomina = @IdTipoNomina AND Codigo = @CodigoPeriodo ;

            INSERT INTO #Tabla(IdEmpleado, Empleado, Nombre, Codigo, Concepto, Dias, Gravado, Exento, Otros, Tipo, IdPeriodo)
            SELECT @IdEmpleado,
                   @CodigoEmpleado,
                   @NombreEmpleado,
                   @Concepto,
                   @Nombre,
                   @DiasX,
                   @Gravado,
                   @Exento,
                   @Otros,
                   @Tipo,
                   @IdPeriodo ;

        END ;

        FETCH NEXT FROM Foreach
        INTO @Empleado,
             @Concepto,
             @Nombre,
             @Dias,
             @Gravado,
             @Exento,
             @Otros,
             @Tipo,
             @CodigoPeriodo ;
    END ;

    CLOSE Foreach ;
    DEALLOCATE Foreach ;

    UPDATE tbl
    SET IdBienServicio = PercepcionDeduccion.IdBienServicio
    FROM #Tabla tbl
    INNER JOIN dbo.tGRLbienesServicios PercepcionDeduccion ON PercepcionDeduccion.Codigo COLLATE DATABASE_DEFAULT = tbl.Codigo COLLATE DATABASE_DEFAULT
    INNER JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = PercepcionDeduccion.IdEstatusActual
    WHERE EstatusBien.IdEstatus = 1 AND PercepcionDeduccion.IdTipoD = 1452 ;



    IF EXISTS (SELECT 1 FROM #Tabla WHERE IdEmpleado = 0)
    BEGIN
        SELECT IdEstatus = 39,
               [Información] = 'Faltan Empleados',
               IdEmpleado,
               Empleado,
               Nombre
        FROM #Tabla
        WHERE IdEmpleado = 0
        GROUP BY IdEmpleado,
                 Empleado,
                 Nombre ;

        RETURN 0 ;
    END ;

    INSERT INTO dbo.tNOMcalculosEmpleados(IdCalculoE, IdEmpleado, AntiguedadSemanas, DiasTrabajados, SD, SBC, SDI, SUBE, ISR, SubsidioCausado, FechaIngreso)
    SELECT tmp.IdCalculoE,
           tmp.IdEmpleado,
           0,
           Dias,
           0,
           0,
           0,
           0,
           0,
           0,
           '19000101'
    FROM(SELECT DISTINCT t.IdPeriodo,
                         t.IdEmpleado,
                         t.Dias,
                         e.IdCalculoE
         FROM #Tabla t
         INNER JOIN dbo.tNOMcalculosE e ON e.IdPeriodoNomina = t.IdPeriodo) AS tmp
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.tNOMcalculosEmpleados emp
                      WHERE emp.IdEmpleado = tmp.IdEmpleado AND emp.IdCalculoE = tmp.IdCalculoE) ;

    IF EXISTS (SELECT 1 FROM #Tabla WHERE IdBienServicio IS NULL)
    BEGIN
        SELECT IdEstatus = 39,
               [Información] = 'Faltan Percepciones Deducciones',
               Codigo,
               Concepto,
               Tipo
        FROM #Tabla
        WHERE IdBienServicio IS NULL
        GROUP BY Codigo,
                 Concepto,
                 Tipo ;

        RETURN 0 ;
    END ;

    IF EXISTS (SELECT 1 FROM #Tabla WHERE IdPeriodo IS NULL)
    BEGIN
        SELECT IdEstatus = 39,
               [Información] = 'Faltan Periodos',
               Empleado,
               Nombre,
               Concepto
        FROM #Tabla
        WHERE IdPeriodo IS NULL ;

        RETURN 0 ;
    END ;

    /*==================================================================
				3.- SE REGISTRAN LOS CALCULOS POR TRABAJADOR
	  ===================================================================*/
    INSERT INTO dbo.tNOMcalculos(IdCalculoE, IdPeriodoNomina, IdEmpleado, IdBienServicio, Inicial, Valor, Valor2, ImporteGravado, ImporteExento, Formula, IdEstatus)
    SELECT tmp.IdCalculoE,
           tmp.IdPeriodoNomina,
           tmp.IdEmpleado,
           tmp.IdBienServicio,
           0,
           0,
           0,
           tmp.ImporteGravado,
           tmp.ImporteExento,
           Formula,
           tmp.IdEstatus
    FROM(SELECT Tabla.IdPeriodo,
                Tabla.IdEmpleado,
                Tabla.Dias,
                CalculoE.IdCalculoE,
                CalculoE.IdPeriodoNomina,
                Tabla.IdBienServicio,
                ImporteGravado = Tabla.Gravado,
                ImporteExento = (Tabla.Exento + Tabla.Otros),
                Formula = '',
                IdEstatus = 1
         FROM #Tabla Tabla
         INNER JOIN dbo.tNOMcalculosE CalculoE ON CalculoE.IdPeriodoNomina = Tabla.IdPeriodo) AS tmp
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.tNOMcalculos emp
                      WHERE emp.IdEmpleado = tmp.IdEmpleado AND emp.IdCalculoE = tmp.IdCalculoE AND emp.IdPeriodoNomina = tmp.IdPeriodoNomina AND emp.IdBienServicio = tmp.IdBienServicio) ;

    /* ====================================================================
		4.- SE VALIDAN DIFERENCIAS 
	   =====================================================================  */


    DECLARE @ValidacionesNomina TABLE
    (
        Concepto VARCHAR(100) NULL,
        PercepcionDeduccion VARCHAR(100) NULL,
        TotalLayout DECIMAL(18, 2) NULL,
        TotalNomina DECIMAL(18, 2) NULL,
        Diferencia DECIMAL(18, 2) NULL
    ) ;

    INSERT INTO @ValidacionesNomina(Concepto, PercepcionDeduccion, TotalLayout, TotalNomina, Diferencia)
    SELECT tmp.Concepto,
           tmp2.PercepcionDeduccion,
           Layout = tmp.Total,
           Nomina = tmp2.Total,
           Diferencia = tmp.Total - tmp2.Total
    FROM(SELECT Concepto = IIF(F3 = 'Fomento a la Educacion', '99.5', Concepto),
                Total = ROUND(SUM([Perc# Gravada] + [Perc# Exenta] + [Perc# Otros] + Deducciones + Obligaciones), 2),
                Periodo = CONCAT(periodo, '')
         FROM ##PercepcionesDeducciones
         WHERE Empleado IS NULL AND F3 IS NOT NULL
         GROUP BY IIF(F3 = 'Fomento a la Educacion', '99.5', Concepto),
                  CONCAT(periodo, '')) AS tmp
    LEFT JOIN(SELECT Codigo = REPLACE(BienServicio.Codigo, 'D', '.5'),
                     PercepcionDeduccion = BienServicio.Descripcion,
                     Total = ROUND(SUM(Calculo.ImporteGravado + Calculo.ImporteExento), 2),
                     Periodo = CONCAT(Periodo.Codigo, '')
              FROM dbo.tNOMcalculos Calculo
              LEFT JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = Calculo.IdPeriodoNomina
              LEFT JOIN dbo.tGRLbienesServicios BienServicio ON BienServicio.IdBienServicio = Calculo.IdBienServicio
              LEFT JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = BienServicio.IdEstatusActual
              WHERE Calculo.IdEstatus != 18 AND BienServicio.IdTipoD = 1452 AND EstatusBien.IdEstatus = 1
              GROUP BY REPLACE(BienServicio.Codigo, 'D', '.5'),
                       BienServicio.Descripcion,
                       CONCAT(Periodo.Codigo, '')) AS tmp2 ON tmp2.Codigo COLLATE Modern_Spanish_CI_AI = tmp.Concepto AND tmp.Periodo = tmp2.Periodo COLLATE Modern_Spanish_CI_AI
    ORDER BY CAST(tmp.Concepto AS NUMERIC(18, 2)) ;

    IF EXISTS (SELECT 1 FROM @ValidacionesNomina WHERE Diferencia > 0)
    BEGIN
        SELECT IdEstatus = 39,
               [Información] = 'DIFERENCIAS',
               Concepto,
               PercepcionDeduccion,
               TotalLayout,
               TotalNomina,
               Diferencia
        FROM @ValidacionesNomina ;

        RETURN 0 ;
    END ;

    /* ===================================================================  
				5.- SE INSERTA LA NOMINA DE ACUERDO A LOS TIPOS DE CALCULO
	   ===================================================================*/

    DECLARE @CalculoNomina AS TABLE
    (
        Id INT IDENTITY(1, 1),
        IdCalculoE INT NOT NULL,
        IdNomina INT NOT NULL,
        IdTipoNomina INT NOT NULL
    ) ;
    /*
	SE INSERTA EN TABLA TEMPORAL, EL CÁLCULO ACTIVO.
	*/
    INSERT INTO @CalculoNomina(IdCalculoE, IdTipoNomina)
    SELECT Calculo.IdCalculoE,
           Calculo.IdTipoNomina
    FROM dbo.tNOMcalculosE Calculo WITH(NOLOCK)
    INNER JOIN dbo.tNOMtiposNominas TipoNomina WITH(NOLOCK)ON TipoNomina.IdTipoNomina = Calculo.IdTipoNomina
    INNER JOIN dbo.tNOMperiodos Periodo WITH(NOLOCK)ON Periodo.IdTipoNomina = TipoNomina.IdTipoNomina AND Calculo.IdPeriodoNomina = Periodo.IdPeriodoNomina
    WHERE TipoNomina.IdTipoNomina = @IdTipoNomina AND Periodo.Codigo = @PeriodoNomina AND Calculo.IdEstatus <> 7 ;

    IF NOT EXISTS (SELECT Id, IdCalculoE, IdNomina FROM @CalculoNomina WHERE Id > 0)
    BEGIN
        SELECT IdEstatus = 39, [Información] = 'NO HAY CÁLCULO' ;
        RETURN 0 ;
    END ;

    /*===================================================================
					6.- SE REGISTRA LA NOMINA
	 ===================================================================*/
    DECLARE @FolioNomina INT = ISNULL((SELECT TOP(1)Folio = MAX(Folio) + 1
                                       FROM dbo.tNOMnominas WITH(NOLOCK)
                                       ORDER BY Folio),
                                      1) ;

    INSERT INTO dbo.tNOMnominas(Folio, Fecha, Concepto, IdPeriodo, FechaPago, FechaInicioPago, FechaFinPago, IdSucursal, IdEstatus, IdUsuarioAlta, FiltroSucursal, IdCalculoE, IdDivisa, FactorDivisa, Alta)
    SELECT Folio = @FolioNomina + ROW_NUMBER() OVER (ORDER BY tmp.IdCalculoE),
           Fecha = Periodo.FechaPago,
           Concepto = CONCAT(' NOMINA ', Periodo.Codigo),
           IdPeriodo = dbo.fGETidPeriodo(Periodo.FechaPago),
           @FechaPago,
           Periodo.Inicio,
           Periodo.Fin,
           IdSucursal = @IdSucursal,
           IdEstatus = 1,
           IdUsuarioAlta = -1,
           FiltroSucursal = '',
           CalculoE.IdCalculoE,
           IdDivisa = 1,
           FactorDivisa = 1,
           Alta = CURRENT_TIMESTAMP
    FROM dbo.tNOMcalculosE CalculoE
    INNER JOIN @CalculoNomina tmp ON tmp.IdCalculoE = CalculoE.IdCalculoE
    INNER JOIN dbo.tNOMRegistrosPatronales RegistroPatronal ON RegistroPatronal.IdRegistroPatronal = CalculoE.IdRegistroPatronal
    INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = CalculoE.IdPeriodoNomina
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.tNOMnominas nom WITH(NOLOCK)
                      WHERE nom.IdEstatus = 1 AND nom.IdCalculoE = CalculoE.IdCalculoE) ;

    UPDATE Calculo
    SET Calculo.IdNomina = Nomina.IdNomina
    FROM dbo.tNOMnominas Nomina WITH(NOLOCK)
    INNER JOIN @CalculoNomina Calculo ON Calculo.IdCalculoE = Nomina.IdCalculoE
    WHERE Nomina.IdEstatus = 1 ;

    /*===================================================================
			7.- SE REGISTRA LA RELACION DE NOMINA CON EMPLEADOS
	  ===================================================================*/
    INSERT INTO dbo.tNOMnominasEmpleados(IdEmpleado, IdNomina, IdEstatus, IdAuxiliarSueldo)
    SELECT CalEmp.IdEmpleado,
           Nomina.IdNomina,
           IdEstatus = 1,
           Empleado.IdAuxiliarSueldo
    FROM dbo.tNOMcalculosEmpleados CalEmp
    INNER JOIN dbo.tPERempleados Empleado ON Empleado.IdEmpleado = CalEmp.IdEmpleado
    INNER JOIN dbo.tNOMnominas Nomina ON Nomina.IdCalculoE = CalEmp.IdCalculoE
    INNER JOIN @CalculoNomina tmp ON tmp.IdCalculoE = Nomina.IdCalculoE
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.tNOMnominasEmpleados ne
                      WHERE ne.IdEmpleado = CalEmp.IdEmpleado AND ne.IdNomina = Nomina.IdNomina) ;


    /*====================================================================================
			8.- SE REGISTRA LA RELACION DE PERCEPCIONES DEDUCCIONES A LAS NÓMINAS RELACIONADAS.
	  ===================================================================================== */
    INSERT INTO dbo.tNOMnominasPercepcionesDeducciones(RelNominaEmpleado, IdBienServicio, EsPercepcion, PercepcionDeduccion, Concepto, IdTipoDpercepcionDeduccion, ImporteGravado, ImporteExento, Importe, Otros, IdCuentaABCD, IdAuxiliar, IdDivision, IdNomina, IdEmpleado)
    SELECT NominaEmpleado.IdNominaEmpleado,
           Calculo.IdBienServicio,
           BienServicio.EsPercepcion,
           BienServicio.Codigo,
           BienServicio.Descripcion,
           BienServicio.IdTipoDpercepcionDeduccion,
           ImporteGravado = CASE WHEN BienServicio.IdTipoDaplicacion IN (-1524, -1523) THEN 0
                                 ELSE ISNULL(Calculo.ImporteGravado, 0)
                            END,
           ImporteExento = CASE WHEN BienServicio.IdTipoDaplicacion IN (-1524, -1523) THEN 0
                                ELSE ISNULL(Calculo.ImporteExento, 0)
                           END,
           --APLICA PARA PRESTAMOS Y VIATICOS
           Importe = CASE WHEN BienServicio.IdTipoDaplicacion = -1523 THEN ISNULL(Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL(Calculo.Otros, 0), 0)
                          ELSE 0
                     END,
           Otros = CASE WHEN BienServicio.IdTipoDaplicacion = -1524 THEN ISNULL(Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL(Calculo.Otros, 0), 0)
                        ELSE 0
                   END,
           BienServicio.IdCuentaABCD,
           BienServicio.IdAuxiliar,
           BienServicio.IdDivision,
           NominaEmpleado.IdNomina,
           NominaEmpleado.IdEmpleado
    FROM dbo.tNOMcalculos Calculo
    INNER JOIN dbo.tGRLbienesServicios BienServicio ON BienServicio.IdBienServicio = Calculo.IdBienServicio
    INNER JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = BienServicio.IdEstatusActual
    INNER JOIN dbo.tNOMnominas Nomina ON Nomina.IdCalculoE = Calculo.IdCalculoE
    INNER JOIN dbo.tNOMnominasEmpleados NominaEmpleado ON NominaEmpleado.IdNomina = Nomina.IdNomina AND NominaEmpleado.IdEmpleado = Calculo.IdEmpleado
    INNER JOIN @CalculoNomina tmp ON tmp.IdCalculoE = Nomina.IdCalculoE
    INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = NominaEmpleado.IdEmpleado
    WHERE(ISNULL(Calculo.ImporteGravado, 0) + ISNULL(Calculo.ImporteExento, 0) + ISNULL(Calculo.Otros, 0)) <> 0 AND EstatusBien.IdEstatus = 1 AND NOT EXISTS (SELECT 1
                                                                                                                                                              FROM dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion
                                                                                                                                                              WHERE PercepcionDeduccion.IdNomina = NominaEmpleado.IdNomina AND PercepcionDeduccion.IdBienServicio = Calculo.IdBienServicio)
    ORDER BY Calculo.IdEmpleado,
             CASE WHEN BienServicio.IdTipoDaplicacion IN (-1523, -1524) THEN 3
                  WHEN BienServicio.EsPercepcion = 1 THEN 1
                  ELSE 2
             END,
             Calculo.IdBienServicio ;

    UPDATE Percepcion
    SET Percepcion.ImporteGravado = ABS(Percepcion.ImporteGravado),
        Percepcion.ImporteExento = ABS(Percepcion.ImporteExento)
    FROM dbo.tNOMnominasPercepcionesDeducciones Percepcion
    INNER JOIN @CalculoNomina Calculo ON Calculo.IdNomina = Percepcion.IdNomina
    WHERE Percepcion.IdAuxiliar <> 0 AND Percepcion.IdDivision = 0 ;

    UPDATE Percepcion
    SET Percepcion.IdCuentaABCD = ISNULL(Empleado.IdCuentaABCD, 0)
    FROM dbo.tNOMnominasPercepcionesDeducciones Percepcion
    INNER JOIN @CalculoNomina Calculo ON Calculo.IdNomina = Percepcion.IdNomina
    INNER JOIN dbo.tGRLbienesServicios BienServicio ON BienServicio.IdBienServicio = Percepcion.IdBienServicio
    INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = Percepcion.IdEmpleado
    WHERE BienServicio.IdTipoDdeudorPercepcion = 2520 ; -- SALDO DEL ACREEDOR EMPLEADO


    /* ====================================================================================
			10.- PROVISIONAMOS A DEUDORES COMO INFONAVIT, HACIENDA Y OTROS
	   ==================================================================================== */
    UPDATE PercepcionDeduccion
    SET IdSaldo = ISNULL(Saldo.IdSaldo, 0)
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase Base
    INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion WITH(NOLOCK)ON PercepcionDeduccion.IdNominaPercepcionDeduccion = Base.IdNominaPercepcionDeduccion
    INNER JOIN dbo.tCNTauxiliares Auxiliar WITH(NOLOCK)ON Auxiliar.IdAuxiliar = Base.IdAuxiliar
    INNER JOIN dbo.tGRLbienesServicios Bien WITH(NOLOCK)ON Bien.IdBienServicio = Base.IdBienServicio
    INNER JOIN dbo.tCTLestatusActual EstatusBien WITH(NOLOCK)ON EstatusBien.IdEstatusActual = Bien.IdEstatusActual
    INNER JOIN @CalculoNomina CalNomina ON CalNomina.IdNomina = PercepcionDeduccion.IdNomina
    LEFT JOIN(SELECT Saldo.IdSaldo,
                     Saldo.Codigo,
                     Saldo.Descripcion,
                     Saldo.IdAuxiliar,
                     Saldo.IdCuentaABCD,
                     Saldo.IdSucursal
              FROM dbo.tSDOsaldos Saldo WITH(NOLOCK)
              JOIN dbo.tCTLsucursales Sucursal WITH(NOLOCK)ON Sucursal.IdSucursal = Saldo.IdSucursal
              WHERE Saldo.IdCuentaABCD <> 0 AND Saldo.IdAuxiliar <> 0 AND Saldo.IdEstatus = 1) AS Saldo ON Saldo.IdAuxiliar = PercepcionDeduccion.IdAuxiliar AND Saldo.IdCuentaABCD = PercepcionDeduccion.IdCuentaABCD AND Base.IdSucursal = Saldo.IdSucursal
    WHERE EstatusBien.IdEstatus = 1 AND Base.IdSaldoDestino = 0 AND Base.IdTipoDaplicacion IN (1522, 1576) ;

    /* ====================================================================================
				10.- APLICAMOS A DEUDORES COMO INFONAVIT, HACIENDA Y OTROS
	   ==================================================================================== */
    UPDATE PercepcionDeduccion
    SET IdSaldo = ISNULL(Saldo.IdSaldo, 0)
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase Base
    INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion ON PercepcionDeduccion.IdNominaPercepcionDeduccion = Base.IdNominaPercepcionDeduccion
    INNER JOIN dbo.tCNTauxiliares Auxiliar ON Auxiliar.IdAuxiliar = Base.IdAuxiliar
    INNER JOIN dbo.tGRLbienesServicios BienPercepcionDeduccion ON BienPercepcionDeduccion.IdBienServicio = Base.IdBienServicio
    INNER JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = BienPercepcionDeduccion.IdEstatusActual
    INNER JOIN @CalculoNomina CalNomina ON CalNomina.IdNomina = PercepcionDeduccion.IdNomina
    LEFT JOIN(SELECT Saldo.IdSaldo,
                     Saldo.Codigo,
                     Saldo.Descripcion,
                     Saldo.IdAuxiliar,
                     Saldo.IdCuentaABCD,
                     Saldo.IdSucursal
              FROM dbo.tSDOsaldos Saldo
              INNER JOIN dbo.tCTLsucursales Sucursal ON Sucursal.IdSucursal = Saldo.IdSucursal
              WHERE Saldo.IdCuentaABCD <> 0 AND Saldo.IdAuxiliar <> 0 AND Saldo.IdEstatus = 1) AS Saldo ON Saldo.IdAuxiliar = PercepcionDeduccion.IdAuxiliar AND Saldo.IdCuentaABCD = PercepcionDeduccion.IdCuentaABCD AND Saldo.IdSucursal = Base.IdSucursal
    WHERE EstatusBien.IdEstatus = 1 AND Base.IdSaldoDestino = 0 AND Base.IdTipoDaplicacion IN (-1524, 1524, 2662, 1586) ;

    /* ====================================================================================
				11.- BUSCAMOS LOS SALDOS DEL EMPLEADO PARA SU APLICACION POR SUCURSAL
	   ==================================================================================== */
    UPDATE PercepcionDeduccion
    SET IdSaldo = ISNULL(Saldo.IdSaldo, 0)
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase Base
    INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion WITH(NOLOCK)ON PercepcionDeduccion.IdNominaPercepcionDeduccion = Base.IdNominaPercepcionDeduccion
    INNER JOIN dbo.tCNTauxiliares Auxiliar WITH(NOLOCK)ON Auxiliar.IdAuxiliar = Base.IdAuxiliar
    INNER JOIN dbo.tGRLbienesServicios BienPercepcionDeduccion WITH(NOLOCK)ON BienPercepcionDeduccion.IdBienServicio = Base.IdBienServicio
    INNER JOIN dbo.tCTLestatusActual EstatusBien WITH(NOLOCK)ON EstatusBien.IdEstatusActual = BienPercepcionDeduccion.IdEstatusActual
    INNER JOIN @CalculoNomina CalNomina ON CalNomina.IdNomina = PercepcionDeduccion.IdNomina
    LEFT JOIN(SELECT Saldo.IdSaldo,
                     Saldo.Codigo,
                     Saldo.Descripcion,
                     Saldo.IdAuxiliar,
                     Saldo.IdCuentaABCD,
                     Saldo.IdSucursal,
                     Saldo.IdPersona,
                     Numero = ROW_NUMBER() OVER (PARTITION BY Saldo.IdPersona,
                                                              Saldo.IdAuxiliar,
                                                              Saldo.IdSucursal
                                                 ORDER BY Saldo.IdPersona,
                                                          Saldo.IdAuxiliar,
                                                          Saldo.Saldo DESC)
              FROM dbo.tSDOsaldos Saldo WITH(NOLOCK)
              WHERE Saldo.IdCuentaABCD <> 0 AND Saldo.IdAuxiliar <> 0 AND Saldo.IdEstatus = 1) AS Saldo ON Saldo.IdAuxiliar = PercepcionDeduccion.IdAuxiliar AND Saldo.IdPersona = Base.IdPersona AND Saldo.IdSucursal = Base.IdSucursal
    WHERE EstatusBien.IdEstatus = 1 AND Base.IdSaldoDestino = 0 AND Base.IdTipoDaplicacion = 1523 AND Auxiliar.IdAuxiliar <> 0 AND ISNULL(Saldo.IdSaldo, 0) <> 0 ;
    /* ====================================================================================
			12.- CREAMOS LAS TRANSACCIONES DEL SUELDOS
	   ==================================================================================== */



    IF EXISTS (SELECT 1
               FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
               WHERE NOT EXISTS (SELECT oper.IdEmpleado
                             FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
                             INNER JOIN @CalculoNomina nom ON nom.IdNomina = oper.IdNomina
                             WHERE ISNULL(oper.IdSaldoDestino, 0) = 0))
    BEGIN
        SELECT IdEstatus = 39,
               [Información] = 'NO EXISTEN SALDOS DE SUELDOS PARA LOS EMPLEADOS',
               oper.Descripcion,
               oper.IdEmpleado
        FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
        WHERE NOT EXISTS (SELECT oper.IdEmpleado
                      FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
                      INNER JOIN @CalculoNomina n ON n.IdNomina = oper.IdNomina
                      WHERE ISNULL(oper.IdSaldoDestino, 0) = 0) ;

        RETURN 0 ;
    END ;

    IF EXISTS (SELECT DISTINCT bsd.IdBienServicio,
                               a.IdAuxiliar,
                               a.Codigo,
                               a.Descripcion,
                               s.IdTipoDaplicacion,
                               bsd.IdCuentaABCD
               FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase s
               INNER JOIN @CalculoNomina n ON n.IdNomina = s.IdNomina
               INNER JOIN dbo.tGRLbienesServicios bsd ON bsd.IdBienServicio = s.IdBienServicio
               INNER JOIN dbo.tCTLestatusActual Estatus WITH(NOLOCK)ON Estatus.IdEstatusActual = bsd.IdEstatusActual
               INNER JOIN dbo.tCNTauxiliares a ON a.IdAuxiliar = s.IdAuxiliar
               WHERE Estatus.IdEstatus = 1 AND s.IdSaldoDestino = 0)
    BEGIN
        SELECT DISTINCT IdEstatus = 39,
                        [Información] = 'NO EXISTE EL SALDO',
                        [Percepcion / Deducción] = CONCAT(BienServicio.IdBienServicio, '=', BienServicio.Descripcion),
                        [Deudor / Acreedor] = CONCAT(ABCD.IdCuentaABCD, '=', ABCD.Descripcion),
                        [Tipo Saldo] = CONCAT(Auxiliar.IdAuxiliar, '=', Auxiliar.Descripcion),
                        [Aplica A] = CONCAT(Aplicacion.IdTipoD, '=', Aplicacion.Descripcion),
                        IdEmpleado = Empleado.IdEmpleado,
                        Empleado = Empleado.Nombre,
                        Sucursal = CONCAT(sucursal.Codigo, ' ', sucursal.Descripcion)
        FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase TransaccionSueldos
        INNER JOIN @CalculoNomina Nomina ON Nomina.IdNomina = TransaccionSueldos.IdNomina
        INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = TransaccionSueldos.IdEmpleado
        INNER JOIN dbo.tCTLsucursales sucursal ON sucursal.IdSucursal = Empleado.IdSucursal
        INNER JOIN dbo.tGRLbienesServicios BienServicio ON BienServicio.IdBienServicio = TransaccionSueldos.IdBienServicio
        INNER JOIN dbo.tCTLestatusActual EstatusBien WITH(NOLOCK)ON EstatusBien.IdEstatusActual = BienServicio.IdEstatusActual
        INNER JOIN dbo.tCNTauxiliares Auxiliar ON Auxiliar.IdAuxiliar = TransaccionSueldos.IdAuxiliar
        INNER JOIN dbo.tCTLtiposD Aplicacion ON Aplicacion.IdTipoD = TransaccionSueldos.IdTipoDaplicacion
        INNER JOIN dbo.tGRLcuentasABCD ABCD ON ABCD.IdCuentaABCD = BienServicio.IdCuentaABCD
        WHERE TransaccionSueldos.IdSaldoDestino = 0 AND EstatusBien.IdEstatus = 1 ;

        RETURN 0;
    END ;

    /* ====================================================================================
			13.- VALIDAMOS QUE EL SALDO DE SUELDOS NO ESTE REPETIDO
	 ==================================================================================== */

    IF EXISTS (SELECT Provision.IdPersona
               FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos Provision
               INNER JOIN dbo.tSDOsaldos Saldo WITH(NOLOCK)ON Provision.IdSaldoDestino = Saldo.IdSaldo
               INNER JOIN dbo.tCTLsucursales Sucursal WITH(NOLOCK)ON Sucursal.IdSucursal = Saldo.IdSucursal
               INNER JOIN @CalculoNomina cal ON cal.IdNomina = Provision.IdNomina
               WHERE NOT EXISTS (SELECT 1
                                 FROM dbo.tSDOtransacciones Transaccion WITH(NOLOCK)
                                 WHERE Transaccion.IdEstatus = 1 AND Transaccion.Fecha = Provision.Fecha AND Transaccion.IdOperacion > 0 AND Transaccion.IdOperacion = Provision.IdOperacion AND Transaccion.IdSaldoDestino = Provision.IdSaldoDestino)
               GROUP BY Provision.IdPersona
               HAVING COUNT(*) > 1)
    BEGIN
        SELECT IdEstatus = 39,
               [Información] = 'REVISAR EL EMPLEADO TIENE SALDOS REPETIDOS',
               Empleado.Nombre
        FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos Provision
        INNER JOIN dbo.vPERempleados Empleado WITH(NOLOCK)ON Provision.IdPersona = Empleado.IdEmpleado
        INNER JOIN dbo.tSDOsaldos Saldo WITH(NOLOCK)ON Provision.IdSaldoDestino = Saldo.IdSaldo
        INNER JOIN dbo.tCTLsucursales Sucursal WITH(NOLOCK)ON Sucursal.IdSucursal = Saldo.IdSucursal
        INNER JOIN @CalculoNomina cal ON cal.IdNomina = Provision.IdNomina
        WHERE NOT EXISTS (SELECT 1
                          FROM dbo.tSDOtransacciones Transaccion WITH(NOLOCK)
                          WHERE Transaccion.IdEstatus = 1 AND Transaccion.Fecha = Provision.Fecha AND Transaccion.IdOperacion > 0 AND Transaccion.IdOperacion = Provision.IdOperacion AND Transaccion.IdSaldoDestino = Provision.IdSaldoDestino)
        GROUP BY Empleado.Nombre
        HAVING COUNT(*) > 1 ;

        RETURN 0
		;
    END ;
    DECLARE @IdOperacionPadre INT = 0 ;

    INSERT INTO dbo.tGRLoperaciones(IdRecurso, Serie, Folio, IdTipoOperacion, Fecha, Concepto, IdPeriodo, IdSucursal, Referencia, IdDivisa, FactorDivisa, IdEstatus, IdUsuarioAlta, Alta, IdTipoDdominio, IdSesion, RequierePoliza, TienePoliza, IdListaDPoliza)
    --EL folio de la nómina sera el mismo para la operación
    SELECT Base.IdRecurso,
           Base.Serie,
           Base.Folio,
           Base.IdTipoOperacion,
           Base.fecha,
           Base.Concepto,
           Base.IdPeriodo,
           Base.IdSucursal,
           Base.Referencia,
           Base.IdDivisa,
           Base.FactorDivisa,
           Base.IdEstatus,
           Base.IdUsuarioAlta,
           Base.Alta,
           Base.IdTipoDdominio,
           Base.IdSesion,
           Base.RequierePoliza,
           Base.TienePoliza,
           Base.IdListaDPoliza
    FROM dbo.vNOMoperacionNominaPadreBase Base
    INNER JOIN @CalculoNomina nom ON nom.IdNomina = Base.IdNomina
    WHERE Base.IdEstatus = 1 AND NOT EXISTS (SELECT 1
                                          FROM dbo.tGRLoperaciones ope WITH(NOLOCK)
                                          WHERE ope.IdRecurso = Base.IdRecurso AND ope.IdTipoOperacion = Base.IdTipoOperacion AND ope.IdEstatus = 1 AND ope.Folio = Base.Folio) ;

    SET @IdOperacionPadre = SCOPE_IDENTITY() ;

    IF(ISNULL(@IdOperacionPadre, 0) = 0)
    BEGIN
        SELECT IdEstatus = 39,
               [Información] = 'NO EXISTE LA OPERACION PARA ASENTAR LA PROVISIÓN DE NÓMINA' ;
        RETURN 0;
    END ;

    UPDATE dbo.tGRLoperaciones
    SET IdOperacionPadre = @IdOperacionPadre,
        RelOperaciones = @IdOperacionPadre
    WHERE IdOperacionPadre = 0 AND IdOperacion = @IdOperacionPadre ;

    UPDATE Nomina
    SET IdOperacion = @IdOperacionPadre
    FROM dbo.tNOMnominas Nomina WITH(NOLOCK)
    INNER JOIN @CalculoNomina Calculo ON Calculo.IdNomina = Nomina.IdNomina AND Calculo.IdCalculoE = Nomina.IdCalculoE
    WHERE Nomina.IdOperacion = 0 ;


    INSERT INTO tGRLoperaciones(IdRecurso, Serie, Folio, IdTipoOperacion, Fecha, Concepto, Referencia, IdPersona, IdPeriodo, IdSucursal, IdDivisa, FactorDivisa, RelOperaciones, RelOperacionesD, RelTransacciones, IdCuentaABCD, TienePoliza, IdListaDPoliza, IdEstatus, IdUsuarioAlta, Alta, IdTipoDdominio, IdSesion, RequierePoliza, IdOperacionPadre, AltaLocal)
    -- EL FOLIO DE LA OPERACIÓN DEL RECIBO SERÁ EL IDNOMINAEMPLEADO
    SELECT Base.IdRecurso,
           Base.Serie,
           Base.Folio,
           Base.IdTipoOperacion,
           Base.Fecha,
           Base.Concepto,
           Base.Referencia,
           Base.IdPersona,
           Base.IdPeriodo,
           Base.IdSucursal,
           Base.IdDivisa,
           Base.FactorDivisa,
           Base.RelOperaciones,
           Base.RelOperacionesD,
           Base.RelTransacciones,
           Base.IdCuentaABCD,
           Base.TienePoliza,
           Base.IdListaDPoliza,
           Base.IdEstatus,
           Base.IdUsuarioAlta,
           Base.Alta,
           Base.IdTipoDdominio,
           Base.IdSesion,
           Base.RequierePoliza,
           Base.IdOperacionPadre,
           Base.AltaLocal
    FROM dbo.vNOMoperacionNominaEmpleadosBase Base
    INNER JOIN @CalculoNomina cal ON cal.IdNomina = Base.IdNomina
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.tGRLoperaciones ope WITH(NOLOCK)
                      WHERE ope.IdRecurso = Base.IdRecurso AND ope.IdTipoOperacion = Base.IdTipoOperacion AND ope.IdEstatus = 1 AND ope.Folio = Base.Folio) ;

    UPDATE dbo.tGRLoperaciones
    SET RelOperaciones = IdOperacion,
        RelOperacionesD = IdOperacion,
        RelTransacciones = IdOperacion
    WHERE IdTipoOperacion = 20 AND RelOperaciones = 0 AND IdOperacionPadre = @IdOperacionPadre ;

    -- ACTUALIZAMOS EL IDOPERACION PARA SER ULTIZADO AL CREAR LAS TRANSACCIONES Y OPERACIONESD
    UPDATE nom
    SET IdOperacion = o.IdOperacion
    FROM dbo.tGRLoperaciones o
    JOIN dbo.tPERempleados emp ON emp.IdPersonaFisica = o.IdPersona
    JOIN dbo.tNOMnominasEmpleados nom ON nom.IdEmpleado = emp.IdEmpleado AND nom.IdNominaEmpleado = o.Folio
    JOIN @CalculoNomina Calculo ON nom.IdNomina = Calculo.IdNomina
    WHERE o.IdTipoOperacion = 20 AND nom.IdOperacion = 0 AND o.IdOperacionPadre = @IdOperacionPadre ;

    DISABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    INSERT INTO dbo.tSDOtransacciones(IdOperacion, IdTipoSubOperacion, Fecha, Descripcion, IdSaldoDestino, IdTipoDDominioDestino, IdAuxiliar, IdDivisa, FactorDivisa, MontoSubOperacion, Naturaleza, TotalCargos, CambioNeto, SubTotalGenerado, Concepto, Referencia, IdSucursal, IdEstructuraContableE, IdCentroCostos, IdEstatus, Alta)
    SELECT Provision.IdOperacion,
           Provision.IdTipoSubOperacion,
           Provision.Fecha,
           Provision.Descripcion,
           Provision.IdSaldoDestino,
           Saldo.IdTipoDDominioCatalogo,
           Saldo.IdAuxiliar,
           Saldo.IdDivisa,
           Provision.FactorDivisa,
           Provision.MontoSubOperacion,
           Saldo.Naturaleza,
           Provision.TotalCargos,
           Provision.CambioNeto,
           Provision.SubTotalGenerado,
           Provision.Concepto,
           Provision.Referencia,
           Saldo.IdSucursal,
           Saldo.IdEstructuraContable,
           Sucursal.IdCentroCostos,
           Provision.IdEstatus,
           Alta = CURRENT_TIMESTAMP
    FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos Provision
    INNER JOIN dbo.tSDOsaldos Saldo WITH(NOLOCK)ON Provision.IdSaldoDestino = Saldo.IdSaldo
    INNER JOIN dbo.tCTLsucursales Sucursal WITH(NOLOCK)ON Sucursal.IdSucursal = Saldo.IdSucursal
    INNER JOIN @CalculoNomina cal ON cal.IdNomina = Provision.IdNomina
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.tSDOtransacciones Transaccion
                      WHERE Transaccion.IdEstatus = 1 AND Transaccion.Fecha = Provision.Fecha AND Transaccion.IdOperacion > 0 AND Transaccion.IdOperacion = Provision.IdOperacion AND Transaccion.IdSaldoDestino = Provision.IdSaldoDestino)
   ORDER BY Provision.IdOperacion ;

    ENABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    INSERT INTO dbo.tGRLoperacionesD(RelOperacionD, IdTipoSubOperacion, IdTipoDDominioDestino, IdBienServicio, IdDivision, Concepto, Referencia, IdSucursal, IdCentroCostos, IdEstructuraContableE, ImporteGravado, ImporteExento, ImporteDeduccionGravado, ImporteDeduccionExento, Total, IdEstatus, IdUsuarioAlta, Alta, IdTipoDdominio, IdSesion, IdEstatusDominio)
    SELECT Base.RelOperacionD,
           Base.IdTipoSubOperacion,
           Base.IdTipoDDominioDestino,
           Base.IdBienServicio,
           Base.IdDivision,
           Base.Concepto,
           Base.Referencia,
           Base.IdSucursal,
           Base.IdCentroCostos,
           Base.IdEstructuraContableE,
           Base.ImporteGravado,
           Base.ImporteExento,
           Base.ImporteDeduccionGravado,
           Base.ImporteDeduccionExento,
           Base.Total,
           Base.IdEstatus,
           Base.IdUsuarioAlta,
           Base.Alta,
           Base.IdTipoDdominio,
           Base.IdSesion,
           Base.IdEstatusDominio
    FROM dbo.vNOMoperacionNominaEmpleadosOperacionesDBase Base
    INNER JOIN @CalculoNomina nom ON nom.IdNomina = Base.IdNomina
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.tGRLoperacionesD OperacionD WITH(NOLOCK)
                      WHERE OperacionD.RelOperacionD > 0 AND OperacionD.RelOperacionD = Base.RelOperacionD AND OperacionD.IdEstatus = 1 AND OperacionD.IdBienServicio = Base.IdBienServicio)
    ORDER BY Base.RelOperacionD,
             Base.Orden ;

    DISABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    INSERT INTO dbo.tSDOtransacciones(IdOperacion, IdTipoSubOperacion, Fecha, Descripcion, IdSaldoDestino, IdTipoDDominioDestino, IdAuxiliar, IdBienServicio, IdDivisa, FactorDivisa, Naturaleza, MontoSubOperacion, TotalCargos, TotalAbonos, CambioNeto, SubTotalGenerado, SubTotalPagado, Concepto, Referencia, IdSucursal, IdEstructuraContableE, IdCentroCostos, IdEstatus, IdUsuarioAlta, Alta, IdSesion, Saldo, SaldoAnterior)
    SELECT Base.IdOperacion,
           Base.IdTipoSubOperacion,
           Base.Fecha,
           Base.Descripcion,
           Base.IdSaldoDestino,
           Base.IdTipoDDominioDestino,
           Base.IdAuxiliar,
           Base.IdBienServicio,
           Base.IdDivisa,
           Base.FactorDivisa,
           Base.Naturaleza,
           Base.MontoSubOperacion,
           Base.TotalCargos,
           Base.TotalAbonos,
           Base.CambioNeto,
           Base.SubTotalGenerado,
           Base.SubTotalPagado,
           Base.Concepto,
           Base.Referencia,
           Base.IdSucursal,
           Base.IdEstructuraContableE,
           Base.IdCentroCostos,
           Base.IdEstatus,
           Base.IdUsuarioAlta,
           Base.Alta,
           Base.IdSesion,
           Base.Saldo,
           Base.SaldoAnterior
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase Base
    INNER JOIN @CalculoNomina Nom ON Nom.IdNomina = Base.IdNomina
    ORDER BY Base.IdOperacion,
             Base.Orden ;

    ENABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    /*CONTABILIZAR LA NOMINA*/
    --BEGIN TRY
    EXEC dbo.pCNTrecontabilizacionOperacion @IdOperacion = @IdOperacionPadre ;

--EXECUTE dbo.pCNTgenerarPolizaBaseDatos @TipoFiltro = 1,
--                                       @IdOperacion = @IdOperacionPadre,
--                                       @IdCierre = 0,
--                                       @IdSucursal = 0,
--                                       @IdUsuario = 0,
--                                       @IdSesion = 0,
--                                       @MostrarPoliza = 1 ;


END ;
GO

