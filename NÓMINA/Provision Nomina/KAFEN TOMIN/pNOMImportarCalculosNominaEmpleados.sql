SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO



ALTER PROC [dbo].[pNOMImportarCalculosNominaEmpleados]
AS
BEGIN
    DECLARE @PeriodoNomina VARCHAR(25) = '' ;
    DECLARE @FechaPago DATE = '19000101' ;
    DECLARE @IdTipoNomina INT ;

    SELECT TOP( 1 )@PeriodoNomina = Periodo,
        @FechaPago = FechaPago,
        @IdTipoNomina = IdTipoNomina
    FROM ##PercepcionesDeducciones
    WHERE Periodo IS NOT NULL
    ORDER BY Id ;
    /*===================================================================
								1.-	CREA EL CALCULO DE NÓMINA
	 ===================================================================  */
    INSERT INTO dbo.tNOMcalculosE( IdEmpresa, IdRegistroPatronal, IdTipoNomina, IdPeriodoNomina, IdTipoDnomina, IdTipoDaplicacion, IdEmpleado, IdSucursal, IdProducto, IdEstatus, IdUsuarioAlta, Alta, IdUsuarioCambio, UltimoCambio, IdObservacionEDominio, IdSesion )
    SELECT IdEmpresa = 1,
        TipoNomina.IdRegistroPatronal,
        TipoNomina.IdTipoNomina,
        IdPeriodoNomina,
        IdTipoDnomina = 1952,
        0,
        0,
        0,
        0,
        IdEstatus = 1,
        0,
        GETDATE (),
        0,
        GETDATE (),
        0,
        0
    FROM dbo.tNOMtiposNominas TipoNomina
    INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdTipoNomina = TipoNomina.IdTipoNomina AND Periodo.Codigo = @PeriodoNomina
    WHERE TipoNomina.IdEstatus = 1 AND NOT EXISTS ( SELECT 1
                                                    FROM tNOMcalculosE Calculo
                                                    WHERE Calculo.IdTipoNomina = TipoNomina.IdTipoNomina AND Calculo.IdPeriodoNomina = Periodo.IdPeriodoNomina AND Calculo.IdEstatus = 1 ) AND TipoNomina.IdRegistroPatronal <> 0 ;

    IF NOT EXISTS ( SELECT 1
                    FROM dbo.tNOMtiposNominas TipoNomina WITH( NOLOCK )
                    INNER JOIN dbo.tNOMperiodos Periodo WITH( NOLOCK )ON Periodo.IdTipoNomina = TipoNomina.IdTipoNomina AND Periodo.Codigo = @PeriodoNomina
                    WHERE TipoNomina.IdEstatus = 1 )
    BEGIN
        SELECT IdEstatus = 39,
            [Información] = 'FALTA EL CÁLCULO' ;
        RETURN ;
    END ;


    DELETE Calculos
    FROM dbo.tNOMcalculosE Calculo
    INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = Calculo.IdPeriodoNomina
    INNER JOIN dbo.tNOMcalculos Calculos ON Calculos.IdCalculoE = Calculo.IdCalculoE
    WHERE Periodo.Codigo = @PeriodoNomina AND Calculo.IdEstatus = 13 ;


    /*==================================================================
		2.- SE ALMACENAN LOS REGISTROS DEL LAYOUT EN LA TABLA DE APOYO.						
	===================================================================*/
    IF OBJECT_ID (N'#Nomina', N'U') IS NOT NULL
        DROP TABLE #Nomina ;

    SELECT Id,
        Empleado = IIF(Empleado IS NULL, NULL, Empleado),
        Concepto = UPPER (Concepto),
        Descripcion = UPPER (F3),
        Dias = Percepciones,
        PGravada = ROUND ([Perc# Gravada], 2),
        PExenta = ROUND ([Perc# Exenta], 2),
        POtros = ROUND ([Perc# Otros], 2),
        Deduccion = ROUND (Deducciones, 2),
        Obligacion = ROUND (Obligaciones, 2),
        Tipo = CASE WHEN ( [Perc# Gravada] + [Perc# Exenta] ) <> 0 THEN
                         1
                    WHEN Deducciones <> 0 THEN
                         2
                    WHEN Obligaciones <> 0 THEN
                         3
                    WHEN [Perc# Otros] <> 0 THEN
                         4
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
        PExenta = ( PExenta + Deduccion ),
        Otros = ( POtros + Obligacion ),
        Tipo,
        Periodo
    FROM #Nomina
    ORDER BY Id ;

    DECLARE @IdEmpleado INT,
        @Empleado       VARCHAR(250),
        @CodigoEmpleado VARCHAR(250),
        @Nombre         VARCHAR(MAX),
        @NombreEmpleado VARCHAR(MAX),
        @Nom            VARCHAR(MAX),
        @Tipo           INT,
        @Concepto       VARCHAR(MAX),
        @Gravado        NUMERIC(28, 3),
        @Exento         NUMERIC(28, 3),
        @Otros          NUMERIC(28, 3),
        @Dias           NUMERIC(18, 2),
        @DiasX          NUMERIC(18, 2),
        @IdPeriodo      INT,
        @CodigoPeriodo  VARCHAR(20) ;

    IF OBJECT_ID (N'#Tabla', N'U') IS NOT NULL
        DROP TABLE #Tabla ;

    CREATE TABLE #Tabla
    (
    IdPeriodo INT,
    IdEmpleado INT,
    Dias NUMERIC(18, 2),
    Empleado VARCHAR(250),
    Nombre VARCHAR(MAX),
    IdBienServicio INT,
    Codigo VARCHAR(MAX),
    Concepto VARCHAR(MAX),
    Gravado NUMERIC(28, 3),
    Exento NUMERIC(28, 3),
    Otros NUMERIC(28, 2),
    Tipo INT
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
        IF @Empleado IS NOT NULL
        BEGIN
            SELECT @IdEmpleado = ISNULL (b.IdEmpleado, 0),
                @CodigoEmpleado = b.Codigo,
                @NombreEmpleado = b.Nombre,
                @DiasX = @Dias
            FROM dbo.vPERempleados b
            WHERE Codigo = @Empleado ;


        END ;
        ELSE
        BEGIN
            SELECT @IdPeriodo = IdPeriodoNomina
            FROM dbo.tNOMperiodos WITH( NOLOCK )
            WHERE IdTipoNomina = @IdTipoNomina AND Codigo = @CodigoPeriodo ;

            INSERT INTO #Tabla( IdEmpleado, Empleado, Nombre, Codigo, Concepto, Dias, Gravado, Exento, Otros, Tipo, IdPeriodo )
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
    SET IdBienServicio = dp.IdBienServicio
    FROM #Tabla tbl
    INNER JOIN dbo.tGRLbienesServicios dp ON dp.Codigo COLLATE DATABASE_DEFAULT = tbl.Codigo COLLATE DATABASE_DEFAULT
    INNER JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = dp.IdEstatusActual
    WHERE EstatusBien.IdEstatus = 1 AND IdTipoD = 1452 ;

    IF EXISTS ( SELECT 1
                FROM #Tabla
                WHERE IdEmpleado = 0 )
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

        RETURN ;
    END ;



    INSERT INTO dbo.tNOMcalculosEmpleados( IdCalculoE, IdEmpleado, AntiguedadSemanas, DiasTrabajados, SD, SBC, SDI, SUBE, ISR, SubsidioCausado, FechaIngreso )
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
    FROM( SELECT DISTINCT t.IdPeriodo,
              t.IdEmpleado,
              t.Dias,
              e.IdCalculoE
          FROM #Tabla t
          INNER JOIN dbo.tNOMcalculosE e ON e.IdPeriodoNomina = @IdPeriodo AND e.IdTipoNomina = @IdTipoNomina ) AS tmp
    WHERE NOT EXISTS ( SELECT 1
                       FROM dbo.tNOMcalculosEmpleados emp
                       WHERE emp.IdEmpleado = tmp.IdEmpleado AND emp.IdCalculoE = tmp.IdCalculoE ) ;


    IF EXISTS ( SELECT 1
                FROM #Tabla
                WHERE IdBienServicio IS NULL )
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

        RETURN ;
    END ;

    IF EXISTS ( SELECT 1
                FROM #Tabla
                WHERE IdPeriodo IS NULL )
    BEGIN
        SELECT IdEstatus = 39,
            [Información] = 'Faltan Periodos',
            Empleado,
            Nombre,
            Concepto
        FROM #Tabla
        WHERE IdPeriodo IS NULL ;

        RETURN ;
    END ;

    /*==================================================================
				3.- SE REGISTRAN LOS CALCULOS POR TRABAJADOR
	  ===================================================================*/
    INSERT INTO dbo.tNOMcalculos( IdCalculoE, IdPeriodoNomina, IdEmpleado, IdBienServicio, Inicial, Valor, Valor2, ImporteGravado, ImporteExento, Formula, IdEstatus )
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
    FROM( SELECT IdPeriodo,
              Tabla.IdEmpleado,
              Dias,
              CalculoE.IdCalculoE,
              CalculoE.IdPeriodoNomina,
              Tabla.IdBienServicio,
              ImporteGravado = Tabla.Gravado,
              ImporteExento = ( Tabla.Exento + Tabla.Otros ),
              Formula = '',
              IdEstatus = 1
          FROM #Tabla Tabla
          INNER JOIN dbo.tNOMcalculosE CalculoE ON CalculoE.IdPeriodoNomina = Tabla.IdPeriodo ) AS tmp
    WHERE NOT EXISTS ( SELECT 1
                       FROM dbo.tNOMcalculos emp
                       WHERE emp.IdEmpleado = tmp.IdEmpleado AND emp.IdCalculoE = tmp.IdCalculoE AND emp.IdPeriodoNomina = tmp.IdPeriodoNomina AND emp.IdBienServicio = tmp.IdBienServicio ) ;

    /* ====================================================================
		4.- SE VALIDAN DIFERENCIAS 
	   =====================================================================  */
    IF OBJECT_ID ('#validacionesNomina') IS NOT NULL
        DROP TABLE #validacionesNomina ;

    CREATE TABLE #validacionesNomina
    (
    Concepto VARCHAR(100),
    PercepcionDeduccion VARCHAR(100),
    TotalLayout DECIMAL(18, 2),
    TotalNomina DECIMAL(18, 2),
    Diferencia DECIMAL(18, 2)
    ) ;

    INSERT INTO #validacionesNomina( Concepto, PercepcionDeduccion, TotalLayout, TotalNomina, Diferencia )
    SELECT tmp.Concepto,
        PercepcionDeduccion,
        Layout = tmp.Total,
        Nomina = tmp2.Total,
        Diferencia = tmp.Total - tmp2.Total
    FROM( SELECT Concepto = IIF(F3 = 'Fomento a la Educacion', '99.5', Concepto),
              Total = ROUND (SUM ([Perc# Gravada] + [Perc# Exenta] + [Perc# Otros] + Deducciones + Obligaciones), 2),
              Periodo = CONCAT (periodo, '')
          FROM ##PercepcionesDeducciones
          WHERE Empleado IS NULL AND F3 IS NOT NULL
          GROUP BY IIF(F3 = 'Fomento a la Educacion', '99.5', Concepto),
              CONCAT (periodo, '')) AS tmp
    LEFT JOIN( SELECT Codigo = REPLACE (BienServicio.Codigo, 'D', '.5'),
                   PercepcionDeduccion = BienServicio.Descripcion,
                   Total = ROUND (SUM (Calculo.ImporteGravado + Calculo.ImporteExento), 2),
                   Periodo = CONCAT (Periodo.Codigo, '')
               FROM dbo.tNOMcalculos Calculo
               LEFT JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = Calculo.IdPeriodoNomina
               LEFT JOIN dbo.tGRLbienesServicios BienServicio ON BienServicio.IdBienServicio = Calculo.IdBienServicio
               LEFT JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = BienServicio.IdEstatusActual
               WHERE Calculo.IdEstatus != 18 AND BienServicio.IdTipoD = 1452 AND EstatusBien.IdEstatus = 1
               GROUP BY REPLACE (BienServicio.Codigo, 'D', '.5'),
                   BienServicio.Descripcion,
                   CONCAT (Periodo.Codigo, '')) AS tmp2 ON tmp2.Codigo COLLATE Modern_Spanish_CI_AI = tmp.Concepto AND tmp.Periodo = tmp2.Periodo COLLATE Modern_Spanish_CI_AI
    ORDER BY CAST(tmp.Concepto AS NUMERIC(18, 2)) ;

    IF EXISTS ( SELECT 1
                FROM #validacionesNomina
                WHERE Diferencia > 0 )
    BEGIN
        SELECT IdEstatus = 39,
            [Información] = 'DIFERENCIAS',
            Concepto,
            PercepcionDeduccion,
            TotalLayout,
            TotalNomina,
            Diferencia
        FROM #validacionesNomina ;

        RETURN ;
    END ;

    /* ===================================================================  
				5.- SE INSERTA LA NOMINA DE ACUERDO A LOS TIPOS DE CALCULO
	   ===================================================================*/
    IF OBJECT_ID ('##CalculoNomina') IS NOT NULL
        DROP TABLE ##CalculoNomina ;

    CREATE TABLE ##CalculoNomina
    (
    Id INT IDENTITY(1, 1),
    IdCalculoE INT,
    IdNomina INT
    ) ;
    /*
	SE INSERTA EN TABLA TEMPORAL, EL CÁLCULO ACTIVO.
	*/
    INSERT INTO ##CalculoNomina( IdCalculoE )
    SELECT Calculo.IdCalculoE
    FROM dbo.tNOMcalculosE Calculo WITH( NOLOCK )
    INNER JOIN tNOMtiposNominas TipoNomina WITH( NOLOCK )ON TipoNomina.IdTipoNomina = Calculo.IdTipoNomina
    INNER JOIN tNOMperiodos Periodo WITH( NOLOCK )ON Periodo.IdTipoNomina = TipoNomina.IdTipoNomina AND Calculo.IdPeriodoNomina = Periodo.IdPeriodoNomina
    WHERE TipoNomina.IdTipoNomina > 0 AND Periodo.Codigo = @PeriodoNomina AND Calculo.IdEstatus <> 7 ;

    IF NOT EXISTS ( SELECT Id,
                        IdCalculoE,
                        IdNomina
                    FROM ##CalculoNomina
                    WHERE Id > 0 )
    BEGIN
        SELECT IdEstatus = 39,
            [Información] = 'NO HAY CÁLCULO' ;
        RETURN ;
    END ;

    DECLARE @IdSucursal INT = 0 ;

    SELECT @IdSucursal = IdSucursal
    FROM tCTLsucursales
    WHERE EsMatriz = 1 ;

    /*===================================================================
					6.- SE REGISTRA LA NOMINA
	 ===================================================================*/
    DECLARE @FolioNomina INT = ISNULL (( SELECT Folio = MAX (Folio) + 1
                                         FROM dbo.tNOMnominas WITH( NOLOCK )), 1) ;

    INSERT INTO tNOMnominas( Folio, Fecha, Concepto, IdPeriodo, FechaPago, FechaInicioPago, FechaFinPago, IdSucursal, IdEstatus, IdUsuarioAlta, FiltroSucursal, IdCalculoE, IdDivisa, FactorDivisa, Alta )
    SELECT Folio = @FolioNomina + ROW_NUMBER () OVER ( ORDER BY tmp.IdCalculoE ),
        Fecha = @FechaPago,
        Concepto = CONCAT (' NOMINA ', Periodo.Codigo),
        IdPeriodo = dbo.fGETidPeriodo (Periodo.FechaPago),
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
    INNER JOIN ##CalculoNomina tmp ON tmp.IdCalculoE = CalculoE.IdCalculoE
    INNER JOIN tNOMRegistrosPatronales RegistroPatronal ON RegistroPatronal.IdRegistroPatronal = CalculoE.IdRegistroPatronal
    INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = CalculoE.IdPeriodoNomina
    WHERE NOT EXISTS ( SELECT 1
                       FROM tNOMnominas nom WITH( NOLOCK )
                       WHERE nom.IdEstatus = 1 AND nom.IdCalculoE = CalculoE.IdCalculoE ) ;

    UPDATE Calculo
    SET Calculo.IdNomina = Nomina.IdNomina
    FROM dbo.tNOMnominas Nomina WITH( NOLOCK )
    INNER JOIN ##CalculoNomina Calculo ON Calculo.IdCalculoE = Nomina.IdCalculoE
    WHERE Nomina.IdEstatus = 1 ;

    /*===================================================================
			7.- SE REGISTRA LA RELACION DE NOMINA CON EMPLEADOS
	  ===================================================================*/
    INSERT INTO tNOMnominasEmpleados( IdEmpleado, IdNomina, IdEstatus, IdAuxiliarSueldo )
    SELECT CalEmp.IdEmpleado,
        Nomina.IdNomina,
        IdEstatus = 1,
        Empleado.IdAuxiliarSueldo
    FROM tNOMcalculosEmpleados CalEmp
    INNER JOIN dbo.tPERempleados Empleado ON Empleado.IdEmpleado = CalEmp.IdEmpleado
    JOIN tNOMnominas Nomina ON Nomina.IdCalculoE = CalEmp.IdCalculoE
    INNER JOIN ##CalculoNomina tmp ON tmp.IdCalculoE = Nomina.IdCalculoE
    WHERE NOT EXISTS ( SELECT 1
                       FROM tNOMnominasEmpleados ne
                       WHERE ne.IdEmpleado = CalEmp.IdEmpleado AND ne.IdNomina = Nomina.IdNomina ) ;


    /*====================================================================================
			8.- SE REGISTRA LA RELACION DE PERCEPCIONES DEDUCCIONES A LAS NÓMINAS RELACIONADAS.
	  ===================================================================================== */
    INSERT INTO dbo.tNOMnominasPercepcionesDeducciones( RelNominaEmpleado, IdBienServicio, EsPercepcion, PercepcionDeduccion, Concepto, IdTipoDpercepcionDeduccion, ImporteGravado, ImporteExento, Importe, Otros, IdCuentaABCD, IdAuxiliar, IdDivision, IdNomina, IdEmpleado )
    SELECT NominaEmpleado.IdNominaEmpleado,
        Calculo.IdBienServicio,
        BienServicio.EsPercepcion,
        BienServicio.Codigo,
        BienServicio.Descripcion,
        BienServicio.IdTipoDpercepcionDeduccion,
        ImporteGravado = CASE WHEN BienServicio.IdTipoDaplicacion IN (-1524, -1523) THEN
                                   0
                              ELSE ISNULL (Calculo.ImporteGravado, 0)
                         END,
        ImporteExento = CASE WHEN BienServicio.IdTipoDaplicacion IN (-1524, -1523) THEN
                                  0
                             ELSE ISNULL (Calculo.ImporteExento, 0)
                        END,
        --APLICA PARA PRESTAMOS Y VIATICOS
        Importe = CASE WHEN BienServicio.IdTipoDaplicacion = -1523 THEN
                            ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                       ELSE 0
                  END,
        Otros = CASE WHEN BienServicio.IdTipoDaplicacion = -1524 THEN
                          ISNULL (Calculo.ImporteGravado + Calculo.ImporteExento + ISNULL (Calculo.Otros, 0), 0)
                     ELSE 0
                END,
        BienServicio.IdCuentaABCD,
        BienServicio.IdAuxiliar,
        BienServicio.IdDivision,
        NominaEmpleado.IdNomina,
        NominaEmpleado.IdEmpleado
    FROM dbo.tNOMcalculos Calculo
    JOIN dbo.tGRLbienesServicios BienServicio ON BienServicio.IdBienServicio = Calculo.IdBienServicio
    JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = BienServicio.IdEstatusActual
    JOIN dbo.tNOMnominas Nomina ON Nomina.IdCalculoE = Calculo.IdCalculoE
    JOIN dbo.tNOMnominasEmpleados NominaEmpleado ON NominaEmpleado.IdNomina = Nomina.IdNomina AND NominaEmpleado.IdEmpleado = Calculo.IdEmpleado
    INNER JOIN ##CalculoNomina tmp ON tmp.IdCalculoE = Nomina.IdCalculoE
    WHERE ISNULL (Calculo.ImporteGravado, 0) + ISNULL (Calculo.ImporteExento, 0) + ISNULL (Calculo.Otros, 0) <> 0 AND EstatusBien.IdEstatus = 1 AND NOT EXISTS ( SELECT 1
                                                                                                                                                                 FROM dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion
                                                                                                                                                                 WHERE PercepcionDeduccion.RelNominaEmpleado = NominaEmpleado.IdNominaEmpleado AND PercepcionDeduccion.IdBienServicio = Calculo.IdBienServicio )
    ORDER BY Calculo.IdEmpleado,
        CASE WHEN BienServicio.IdTipoDaplicacion IN (-1523, -1524) THEN
                  3
             WHEN BienServicio.EsPercepcion = 1 THEN
                  1
             ELSE 2
        END,
        Calculo.IdBienServicio ;

    UPDATE Percepcion
    SET Percepcion.ImporteGravado = ABS (Percepcion.ImporteGravado),
        Percepcion.ImporteExento = ABS (Percepcion.ImporteExento)
    FROM dbo.tNOMnominasPercepcionesDeducciones Percepcion
    INNER JOIN ##CalculoNomina Calculo ON Calculo.IdNomina = Percepcion.IdNomina
    WHERE Percepcion.IdAuxiliar <> 0 AND Percepcion.IdDivision = 0 ;


    /* ====================================================================================
			10.- PROVISIONAMOS A DEUDORES COMO INFONAVIT, HACIENDA Y OTROS
	   ==================================================================================== */
    UPDATE PercepcionDeduccion
    SET IdSaldo = ISNULL (Saldo.IdSaldo, 0)
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase Base
    INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion WITH( NOLOCK )ON PercepcionDeduccion.IdNominaPercepcionDeduccion = Base.IdNominaPercepcionDeduccion
    INNER JOIN dbo.tCNTauxiliares Auxiliar WITH( NOLOCK )ON Auxiliar.IdAuxiliar = Base.IdAuxiliar
    INNER JOIN dbo.tGRLbienesServicios Bien WITH( NOLOCK )ON Bien.IdBienServicio = Base.IdBienServicio
    INNER JOIN dbo.tCTLestatusActual EstatusBien WITH( NOLOCK )ON EstatusBien.IdEstatusActual = Bien.IdEstatusActual
    INNER JOIN ##CalculoNomina CalNomina ON CalNomina.IdNomina = PercepcionDeduccion.IdNomina
    LEFT JOIN( SELECT Saldo.IdSaldo,
                   Saldo.Codigo,
                   Saldo.Descripcion,
                   Saldo.IdAuxiliar,
                   Saldo.IdCuentaABCD,
                   Saldo.IdSucursal
               FROM dbo.tSDOsaldos Saldo WITH( NOLOCK )
               JOIN tCTLsucursales Sucursal WITH( NOLOCK )ON Sucursal.IdSucursal = Saldo.IdSucursal
               WHERE Saldo.IdCuentaABCD <> 0 AND Saldo.IdAuxiliar <> 0 AND Saldo.IdEstatus = 1 ) AS Saldo ON Saldo.IdAuxiliar = PercepcionDeduccion.IdAuxiliar AND Saldo.IdCuentaABCD = PercepcionDeduccion.IdCuentaABCD AND Base.IdSucursal = Saldo.IdSucursal
    WHERE EstatusBien.IdEstatus = 1 AND IdSaldoDestino = 0 AND Base.IdTipoDaplicacion IN (1522, 1576) ;

    /* ====================================================================================
				10.- APLICAMOS A DEUDORES COMO INFONAVIT, HACIENDA Y OTROS
	   ==================================================================================== */
    UPDATE PercepcionDeduccion
    SET IdSaldo = ISNULL (Saldo.IdSaldo, 0)
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase Base
    INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion ON PercepcionDeduccion.IdNominaPercepcionDeduccion = Base.IdNominaPercepcionDeduccion
    INNER JOIN dbo.tCNTauxiliares Auxiliar ON Auxiliar.IdAuxiliar = Base.IdAuxiliar
    INNER JOIN dbo.tGRLbienesServicios BienPercepcionDeduccion ON BienPercepcionDeduccion.IdBienServicio = Base.IdBienServicio
    INNER JOIN dbo.tCTLestatusActual EstatusBien ON EstatusBien.IdEstatusActual = BienPercepcionDeduccion.IdEstatusActual
    INNER JOIN ##CalculoNomina CalNomina ON CalNomina.IdNomina = PercepcionDeduccion.IdNomina
    LEFT JOIN( SELECT Saldo.IdSaldo,
                   Saldo.Codigo,
                   Saldo.Descripcion,
                   Saldo.IdAuxiliar,
                   Saldo.IdCuentaABCD,
                   Saldo.IdSucursal
               FROM dbo.tSDOsaldos Saldo
               JOIN tCTLsucursales Sucursal ON Sucursal.IdSucursal = Saldo.IdSucursal
               WHERE Saldo.IdCuentaABCD <> 0 AND Saldo.IdAuxiliar <> 0 AND Saldo.IdEstatus = 1 ) AS Saldo ON Saldo.IdAuxiliar = PercepcionDeduccion.IdAuxiliar AND Saldo.IdCuentaABCD = PercepcionDeduccion.IdCuentaABCD AND Saldo.IdSucursal = Base.IdSucursal
    WHERE EstatusBien.IdEstatus = 1 AND IdSaldoDestino = 0 AND Base.IdTipoDaplicacion IN (-1524, 1524, 2662, 1586) ;

    /* ====================================================================================
				11.- BUSCAMOS LOS SALDOS DEL EMPLEADO PARA SU APLICACION POR SUCURSAL
	   ==================================================================================== */
    UPDATE PercepcionDeduccion
    SET IdSaldo = ISNULL (Saldo.IdSaldo, 0)
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase s
    INNER JOIN dbo.tNOMnominasPercepcionesDeducciones PercepcionDeduccion WITH( NOLOCK )ON PercepcionDeduccion.IdNominaPercepcionDeduccion = s.IdNominaPercepcionDeduccion
    INNER JOIN dbo.tCNTauxiliares Auxiliar WITH( NOLOCK )ON Auxiliar.IdAuxiliar = s.IdAuxiliar
    INNER JOIN dbo.tGRLbienesServicios BienPercepcionDeduccion WITH( NOLOCK )ON BienPercepcionDeduccion.IdBienServicio = s.IdBienServicio
    INNER JOIN dbo.tCTLestatusActual EstatusBien WITH( NOLOCK )ON EstatusBien.IdEstatusActual = BienPercepcionDeduccion.IdEstatusActual
    INNER JOIN ##CalculoNomina CalNomina ON CalNomina.IdNomina = PercepcionDeduccion.IdNomina
    LEFT JOIN( SELECT Saldo.IdSaldo,
                   Saldo.Codigo,
                   Saldo.Descripcion,
                   Saldo.IdAuxiliar,
                   Saldo.IdCuentaABCD,
                   Saldo.IdSucursal,
                   Saldo.IdPersona,
                   Numero = ROW_NUMBER () OVER ( PARTITION BY Saldo.IdPersona,
                                                     Saldo.IdAuxiliar,
                                                     Saldo.IdSucursal
                                                 ORDER BY Saldo.IdPersona,
                                                     Saldo.IdAuxiliar,
                                                     Saldo.Saldo DESC )
               FROM dbo.tSDOsaldos Saldo WITH( NOLOCK )
               WHERE Saldo.IdCuentaABCD <> 0 AND Saldo.IdAuxiliar <> 0 AND Saldo.IdEstatus = 1 ) AS Saldo ON Saldo.IdAuxiliar = PercepcionDeduccion.IdAuxiliar AND Saldo.IdPersona = s.IdPersona AND Saldo.IdSucursal = s.IdSucursal
    WHERE EstatusBien.IdEstatus = 1 AND IdSaldoDestino = 0 AND s.IdTipoDaplicacion = 1523 AND Auxiliar.IdAuxiliar <> 0 AND ISNULL (Saldo.IdSaldo, 0) <> 0 ;



    /* ====================================================================================
			12.- CREAMOS LAS TRANSACCIONES DEL SUELDOS
	   ==================================================================================== */
    DECLARE @IdOperacionPadre INT = 0 ;

    IF EXISTS ( SELECT 1
                FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
                WHERE oper.IdEmpleado IN( SELECT oper.IdEmpleado
                                          FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
                                          INNER JOIN ##CalculoNomina nom ON nom.IdNomina = oper.IdNomina
                                          WHERE ISNULL (oper.IdSaldoDestino, 0) = 0 ))
    BEGIN
        SELECT IdEstatus = 39,
            [Información] = 'NO EXISTEN SALDOS PARA LOS EMPLEADOS',
            Descripcion
        FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
        WHERE oper.IdEmpleado IN( SELECT oper.IdEmpleado
                                  FROM dbo.vNOMoperacionNominaEmpleadosProvisionSueldos oper
                                  INNER JOIN ##CalculoNomina n ON n.IdNomina = oper.IdNomina
                                  WHERE ISNULL (oper.IdSaldoDestino, 0) = 0 ) ;

        RETURN ;
    END ;

    IF EXISTS ( SELECT DISTINCT bsd.IdBienServicio,
                    a.IdAuxiliar,
                    a.Codigo,
                    a.Descripcion,
                    s.IdTipoDaplicacion,
                    bsd.IdCuentaABCD
                FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase s
                INNER JOIN ##CalculoNomina n ON n.IdNomina = s.IdNomina
                INNER JOIN dbo.tGRLbienesServicios bsd ON bsd.IdBienServicio = s.IdBienServicio
                INNER JOIN dbo.tCTLestatusActual Estatus WITH( NOLOCK )ON Estatus.IdEstatusActual = bsd.IdEstatusActual
                INNER JOIN dbo.tCNTauxiliares a ON a.IdAuxiliar = s.IdAuxiliar
                WHERE Estatus.IdEstatus = 1 AND IdSaldoDestino = 0 )
    BEGIN
        SELECT DISTINCT IdEstatus = 39,
            [Información] = 'NO EXISTS EL SALDO',
            [Deudor / Acreedor] = CONCAT (ABCD.IdCuentaABCD, '=', ABCD.Descripcion),
            [Tipo Saldo] = CONCAT (a.IdAuxiliar, '=', a.Descripcion),
            [Aplica A] = CONCAT (Aplicacion.IdTipoD, '=', Aplicacion.Descripcion),
            CodEmp = emp.Codigo,
            Empleado = CONCAT (emp.IdEmpleado, '=', emp.Nombre),
            Sucursal = CONCAT (sucursal.Codigo, ' ', sucursal.Descripcion),
            [Percepcion / Deducción] = bsd.Descripcion
        FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase s
        INNER JOIN ##CalculoNomina n ON n.IdNomina = s.IdNomina
        INNER JOIN dbo.vPERempleados emp ON emp.IdEmpleado = s.IdEmpleado
        INNER JOIN dbo.tCTLsucursales sucursal ON sucursal.IdSucursal = emp.IdSucursal
        INNER JOIN dbo.tGRLbienesServicios bsd ON bsd.IdBienServicio = s.IdBienServicio
        INNER JOIN dbo.tCTLestatusActual EstatusBien WITH( NOLOCK )ON EstatusBien.IdEstatusActual = bsd.IdEstatusActual
        INNER JOIN dbo.tCNTauxiliares a ON a.IdAuxiliar = s.IdAuxiliar
        INNER JOIN dbo.tCTLtiposD Aplicacion ON Aplicacion.IdTipoD = s.IdTipoDaplicacion
        INNER JOIN dbo.tGRLcuentasABCD ABCD ON ABCD.IdCuentaABCD = bsd.IdCuentaABCD
        WHERE s.IdSaldoDestino = 0 AND EstatusBien.IdEstatus = 1 ;

        RETURN ;
    END ;

    INSERT INTO tGRLoperaciones( IdRecurso, Serie, Folio, IdTipoOperacion, Fecha, Concepto, IdPeriodo, IdSucursal, Referencia, IdDivisa, FactorDivisa, IdEstatus, IdUsuarioAlta, Alta, IdTipoDdominio, IdSesion, RequierePoliza, TienePoliza, IdListaDPoliza )
    --EL folio de la nómina sera el mismo para la operación
    SELECT IdRecurso,
        Serie,
        Folio,
        IdTipoOperacion,
        fecha,
        Concepto,
        IdPeriodo,
        IdSucursal,
        Referencia,
        IdDivisa,
        FactorDivisa,
        IdEstatus,
        IdUsuarioAlta,
        Alta,
        IdTipoDdominio,
        IdSesion,
        RequierePoliza,
        TienePoliza,
        IdListaDPoliza
    FROM dbo.vNOMoperacionNominaPadreBase n
    INNER JOIN ##CalculoNomina nom ON nom.IdNomina = n.IdNomina
    WHERE n.IdEstatus = 1 AND NOT EXISTS ( SELECT 1
                                           FROM tGRLoperaciones ope WITH( NOLOCK )
                                           WHERE ope.IdRecurso = n.IdRecurso AND ope.IdTipoOperacion = n.IdTipoOperacion AND ope.IdEstatus = 1 AND ope.Folio = n.Folio ) ;

    SET @IdOperacionPadre = SCOPE_IDENTITY () ;

    --IF EXISTS (SELECT 1
    --           FROM tNOMnominas n
    --           INNER JOIN ##CalculoNomina c ON c.IdNomina = n.IdNomina AND c.IdCalculoE = n.IdCalculoE
    --           WHERE IdOperacion != 0 AND n.IdEstatus = 1)
    --BEGIN
    --    SET @IdOperacionPadre = (SELECT IdOperacion
    --                             FROM dbo.tNOMnominas n WITH(NOLOCK)
    --                             INNER JOIN ##CalculoNomina c ON c.IdNomina = n.IdNomina AND c.IdCalculoE = n.IdCalculoE
    --                             WHERE IdOperacion != 0) ;
    --END ;

    IF( ISNULL (@IdOperacionPadre, 0) = 0 )
    BEGIN
        SELECT IdEstatus = 39,
            [Información] = 'NO EXISTE LA OPERACION PARA ASENTAR LA PROVISIÓN DE NÓMINA' ;

        RETURN ;
    END ;

    UPDATE dbo.tGRLoperaciones
    SET IdOperacionPadre = @IdOperacionPadre,
        RelOperaciones = @IdOperacionPadre
    WHERE IdOperacionPadre = 0 AND IdOperacion = @IdOperacionPadre ;

    UPDATE Nomina
    SET IdOperacion = @IdOperacionPadre
    FROM dbo.tNOMnominas Nomina WITH( NOLOCK )
    INNER JOIN ##CalculoNomina Calculo ON Calculo.IdNomina = Nomina.IdNomina AND Calculo.IdCalculoE = Nomina.IdCalculoE
    WHERE IdOperacion = 0 ;

    INSERT INTO tGRLoperaciones( IdRecurso, Serie, Folio, IdTipoOperacion, Fecha, Concepto, Referencia, IdPersona, IdPeriodo, IdSucursal, IdDivisa, FactorDivisa, RelOperaciones, RelOperacionesD, RelTransacciones, IdCuentaABCD, TienePoliza, IdListaDPoliza, IdEstatus, IdUsuarioAlta, Alta, IdTipoDdominio, IdSesion, RequierePoliza, IdOperacionPadre, AltaLocal )
    -- EL FOLIO DE LA OPERACIÓN DEL RECIBO SERÁ EL IDNOMINAEMPLEADO
    SELECT IdRecurso,
        Serie,
        Folio,
        IdTipoOperacion,
        Fecha,
        Concepto,
        Referencia,
        IdPersona,
        IdPeriodo,
        IdSucursal,
        IdDivisa,
        FactorDivisa,
        RelOperaciones,
        RelOperacionesD,
        RelTransacciones,
        IdCuentaABCD,
        TienePoliza,
        IdListaDPoliza,
        IdEstatus,
        IdUsuarioAlta,
        Alta,
        IdTipoDdominio,
        IdSesion,
        RequierePoliza,
        IdOperacionPadre,
        AltaLocal
    FROM vNOMoperacionNominaEmpleadosBase ne
    INNER JOIN ##CalculoNomina cal ON cal.IdNomina = ne.IdNomina
    WHERE NOT EXISTS ( SELECT 1
                       FROM tGRLoperaciones ope WITH( NOLOCK )
                       WHERE ope.IdRecurso = ne.IdRecurso AND ope.IdTipoOperacion = ne.IdTipoOperacion AND ope.IdEstatus = 1 AND ope.Folio = ne.Folio ) ;

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
    JOIN ##CalculoNomina Calculo ON nom.IdNomina = Calculo.IdNomina
    WHERE o.IdTipoOperacion = 20 AND nom.IdOperacion = 0 AND o.IdOperacionPadre = @IdOperacionPadre ;

    DISABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    INSERT INTO tSDOtransacciones( IdOperacion, IdTipoSubOperacion, Fecha, Descripcion, IdSaldoDestino, IdTipoDDominioDestino, IdAuxiliar, IdDivisa, FactorDivisa, MontoSubOperacion, Naturaleza, TotalCargos, CambioNeto, SubTotalGenerado, Concepto, Referencia, IdSucursal, IdEstructuraContableE, IdCentroCostos, IdEstatus, Alta )
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
    INNER JOIN dbo.tSDOsaldos Saldo WITH( NOLOCK )ON Provision.IdSaldoDestino = Saldo.IdSaldo
    INNER JOIN dbo.tCTLsucursales Sucursal WITH( NOLOCK )ON Sucursal.IdSucursal = Saldo.IdSucursal
    INNER JOIN ##CalculoNomina cal ON cal.IdNomina = Provision.IdNomina
    WHERE NOT EXISTS ( SELECT 1
                       FROM dbo.tSDOtransacciones Transaccion
                       WHERE Transaccion.IdEstatus = 1 AND Transaccion.Fecha = Provision.Fecha AND Transaccion.IdOperacion > 0 AND Transaccion.IdOperacion = Provision.IdOperacion AND Transaccion.IdSaldoDestino = Provision.IdSaldoDestino )
    ORDER BY Provision.IdOperacion ;

    ENABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    INSERT INTO tGRLoperacionesD( RelOperacionD, IdTipoSubOperacion, IdTipoDDominioDestino, IdBienServicio, IdDivision, Concepto, Referencia, IdSucursal, IdCentroCostos, IdEstructuraContableE, ImporteGravado, ImporteExento, ImporteDeduccionGravado, ImporteDeduccionExento, Total, IdEstatus, IdUsuarioAlta, Alta, IdTipoDdominio, IdSesion, IdEstatusDominio )
    SELECT RelOperacionD,
        IdTipoSubOperacion,
        IdTipoDDominioDestino,
        IdBienServicio,
        IdDivision,
        Concepto,
        Referencia,
        IdSucursal,
        IdCentroCostos,
        IdEstructuraContableE,
        ImporteGravado,
        ImporteExento,
        ImporteDeduccionGravado,
        ImporteDeduccionExento,
        Total,
        IdEstatus,
        IdUsuarioAlta,
        Alta,
        IdTipoDdominio,
        IdSesion,
        IdEstatusDominio
    FROM dbo.vNOMoperacionNominaEmpleadosOperacionesDBase Base
    INNER JOIN ##CalculoNomina nom ON nom.IdNomina = Base.IdNomina
    WHERE NOT EXISTS ( SELECT 1
                       FROM dbo.tGRLoperacionesD OperacionD WITH( NOLOCK )
                       WHERE OperacionD.RelOperacionD > 0 AND OperacionD.RelOperacionD = Base.RelOperacionD AND OperacionD.IdEstatus = 1 AND OperacionD.IdBienServicio = Base.IdBienServicio )
    ORDER BY RelOperacionD,
        Orden ;

    DISABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    DISABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    INSERT INTO tSDOtransacciones( IdOperacion, IdTipoSubOperacion, Fecha, Descripcion, IdSaldoDestino, IdTipoDDominioDestino, IdAuxiliar, IdBienServicio, IdDivisa, FactorDivisa, Naturaleza, MontoSubOperacion, TotalCargos, TotalAbonos, CambioNeto, SubTotalGenerado, SubTotalPagado, Concepto, Referencia, IdSucursal, IdEstructuraContableE, IdCentroCostos, IdEstatus, IdUsuarioAlta, Alta, IdSesion, Saldo, SaldoAnterior )
    SELECT IdOperacion,
        IdTipoSubOperacion,
        Fecha,
        Descripcion,
        IdSaldoDestino,
        IdTipoDDominioDestino,
        IdAuxiliar,
        IdBienServicio,
        IdDivisa,
        FactorDivisa,
        Naturaleza,
        MontoSubOperacion,
        TotalCargos,
        TotalAbonos,
        CambioNeto,
        SubTotalGenerado,
        SubTotalPagado,
        Concepto,
        Referencia,
        IdSucursal,
        IdEstructuraContableE,
        IdCentroCostos,
        IdEstatus,
        IdUsuarioAlta,
        Alta,
        IdSesion,
        Saldo,
        SaldoAnterior
    FROM dbo.vNOMoperacionNominaEmpleadosTransaccionesBase Base
    INNER JOIN ##CalculoNomina Nom ON Nom.IdNomina = Base.IdNomina
    ORDER BY IdOperacion,
        Orden ;

    ENABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;

    ENABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    EXEC dbo.pCNTrecontabilizacionOperacion @IdOperacion = @IdOperacionPadre ;

    --EXECUTE dbo.pCNTgenerarPolizaBaseDatos @TipoFiltro = 1,
    --                                       @IdOperacion = @IdOperacionPadre,
    --                                       @IdCierre = 0,
    --                                       @IdSucursal = 0,
    --                                       @IdUsuario = 0,
    --                                       @IdSesion = 0,
    --                                       @MostrarPoliza = 1;

    --RETURN 0;
    IF EXISTS ( SELECT 1
                FROM dbo.tGRLoperaciones WITH( NOLOCK )
                WHERE IdOperacion = @IdOperacionPadre AND IdPolizaE > 0 )
    BEGIN
        DISABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;
        DISABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;
        DISABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

        EXECUTE dbo.pSDOactualizarSaldoBaseTransacciones @Operacion = 2 ;
        EXECUTE dbo.pSDOactualizaSaldoAnteriorSaldo @TipoOperacion = '' ;


        DECLARE @IdNomina INT = 0 ;
        SELECT @IdNomina = IdNomina
        FROM ##CalculoNomina ;

        EXECUTE dbo.pCOMgrabarComprobanteFiscalNomina @IdNomina = @IdNomina,
            @IdEmisor = 1 ;


        ENABLE TRIGGER dbo.trValidarDatosTransaccion ON dbo.tSDOtransacciones ;
        ENABLE TRIGGER dbo.trValidarPeriodoModuloTransaccion ON dbo.tSDOtransacciones ;
        ENABLE TRIGGER dbo.trValidarRemesas ON dbo.tSDOtransacciones ;

    END ;

END ;
GO

