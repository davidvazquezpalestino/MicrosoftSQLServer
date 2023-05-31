
/* ==========================================
  Por:  David Vázquez Palestino  1.-
Fecha:  27/03/2020
=============================================*/
IF EXISTS(SELECT OBJECT_ID FROM SYS.VIEWS WHERE OBJECT_ID = OBJECT_ID('vCNTperiodosOrdenados'))
	DROP VIEW dbo.vCNTperiodosOrdenados
GO

CREATE VIEW dbo.vCNTperiodosOrdenados
	AS
SELECT Periodo.IdPeriodo, IdPeriodoAnterior = ISNULL(LAG(Periodo.IdPeriodo) OVER (ORDER BY Ejercicio.Inicio, Periodo.Numero), 0), Consecutivo = ROW_NUMBER() OVER (ORDER BY Ejercicio.Inicio, Periodo.Numero), EjercicioIdEstatus = Estatus.IdEstatus
FROM dbo.tCTLejercicios Ejercicio WITH(NOLOCK)
INNER JOIN dbo.tCTLperiodos Periodo WITH(NOLOCK) ON Periodo.IdEjercicio = Ejercicio.IdEjercicio
INNER JOIN dbo.tCTLestatusActual Estatus WITH(NOLOCK) ON Estatus.IdEstatusActual = Ejercicio.IdEstatusActual
WHERE Estatus.IdEstatus<>2 AND Ejercicio.IdEjercicio<>0;
GO

/* ==========================================
  Por:  David Vázquez Palestino  2.-
Fecha:  27/03/2020
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCNTactualizarAcumuladosContables'))
	DROP PROCEDURE pCNTactualizarAcumuladosContables
GO

CREATE PROC [dbo].[pCNTactualizarAcumuladosContables]
    @TipoOperacion AS INT = 0,
    @IdPolizaE AS     INT = 0,
    @DesdePolizaR AS  BIT = 0,
    @Activar AS       BIT = 0
AS
    BEGIN

    IF( @IdPolizaE = 0 AND @DesdePolizaR = 1 )
        BEGIN
			PRINT 'FIN DE LA EJECUCIÓN';
			RETURN;
        END;

    IF( @IdPolizaE = 0 AND @DesdePolizaR = 0 )
        BEGIN

        --DELETE FROM tCNTacumuladosContables		
        DELETE Acumulado
        FROM tCNTacumuladosContables Acumulado
        INNER JOIN dbo.tCTLperiodos Periodo ON Periodo.IdPeriodo = Acumulado.IdPeriodo
        INNER JOIN dbo.tCTLejercicios Ejercicio ON Ejercicio.IdEjercicio = Periodo.IdEjercicio
        INNER JOIN dbo.tCTLestatusActual Estatus ON Estatus.IdEstatusActual = Ejercicio.IdEstatusActual
        WHERE Estatus.IdEstatus <> 7;

        SET @TipoOperacion = 1;

        UPDATE tce
        SET IdEstatus = 34
        FROM tCNTpolizasE tce
        INNER JOIN
            (   SELECT det.IdPolizaE
                FROM tCNTpolizasD det WITH( NOLOCK )
                INNER JOIN tCNTpolizasE enc WITH( NOLOCK )ON enc.IdPolizaE = det.IdPolizaE
                WHERE IdEstatus = 1
                GROUP BY det.IdPolizaE
                HAVING( ROUND(SUM(Cargo), 2) - ROUND(SUM(Abono), 2)) <> 0 ) AS pol ON pol.IdPolizaE = tce.IdPolizaE;

        UPDATE tce
        SET IdEstatus = 34
        FROM tCNTpolizasE tce
        LEFT JOIN
            ( SELECT DISTINCT tCNTpolizasR.IdPolizaE FROM tCNTpolizasR ) AS res ON res.IdPolizaE = tce.IdPolizaE
        WHERE IdEstatus = 1 AND res.IdPolizaE IS NULL;

        END;

    IF( @Activar = 0 )
    RETURN;

    --	ALMACENA EL PRIMER PERÍODO QUE TIENE MOVIMIENTOS DE PÓLIZAS
    DECLARE @PrimerIdPeriodo AS INT = 0;
    DECLARE @curIdPeriodo AS INT = 0;
    --	OBTIENE EL ÚLTIMO PERIODO CON PÓLIZAS
    DECLARE @UltimoIdPeriodo AS INT = 0;

    SELECT TOP 1 @PrimerIdPeriodo = MIN(Periodo.IdPeriodo) OVER ( ORDER BY Periodo.Consecutivo ),
				 @UltimoIdPeriodo = MAX(Periodo.IdPeriodo) OVER ( ORDER BY Periodo.Consecutivo DESC )
    FROM dbo.tCNTpolizasE Poliza WITH( NOLOCK )
    INNER JOIN dbo.vCNTperiodosOrdenados Periodo WITH( NOLOCK )ON Periodo.IdPeriodo = Poliza.IdPeriodo
    WHERE EjercicioIdEstatus <> 7 AND Poliza.IdPolizaE <> 0;

    --Solo utiliza los periodos para cuando es un relcalculo total                               
    EXEC [dbo].[pCNTagregarAcumuladosContables] @IdPeriodoInicial = @PrimerIdPeriodo, @IdPeriodoFinal = @UltimoIdPeriodo, @IdPolizaE = @IdPolizaE;

    IF( @TipoOperacion = 1 OR @IdPolizaE = 0 )
        BEGIN
			EXEC pCNTactualizarAcumuladosCargosAbonos;
        END;

    EXEC pCNTactualizarResultadoEjercicio @IdPolizaE = @IdPolizaE, @IdPeriodo = @curIdPeriodo;

    IF( @IdPolizaE != 0 )
        BEGIN
			SET @PrimerIdPeriodo = ( SELECT IdPeriodo FROM tCNTpolizasE WHERE IdPolizaE = @IdPolizaE );
        END;

    /* declare variables */
    DECLARE @IdPeriodo INT,
			@IdPeriodoAnterior INT;

    DECLARE PeriodosPolizas CURSOR FAST_FORWARD READ_ONLY FOR
    SELECT	a.IdPeriodo,
			a.IdPeriodoAnterior
    FROM vCNTperiodosOrdenados a
    INNER JOIN vCNTperiodosOrdenados b ON a.Consecutivo >= b.Consecutivo AND b.IdPeriodo = @PrimerIdPeriodo;

    OPEN PeriodosPolizas;

    FETCH NEXT FROM PeriodosPolizas
    INTO @IdPeriodo, @IdPeriodoAnterior;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		EXEC pCNTactualizarAcumuladosResultados @IdPolizaE = @IdPolizaE, @IdPeriodo = @IdPeriodo, @IdPeriodoAnterior = @IdPeriodoAnterior;
		EXEC pCNTactualizarAcumuladosBalance @IdPolizaE = @IdPolizaE, @IdPeriodo = @IdPeriodo, @IdPeriodoAnterior = @IdPeriodoAnterior;

    FETCH NEXT FROM PeriodosPolizas INTO @IdPeriodo, @IdPeriodoAnterior;
    END;

    CLOSE PeriodosPolizas;
    DEALLOCATE PeriodosPolizas;


    EXEC pCNTactualizarAcumuladosNiveles @IdPolizaE = @IdPolizaE;

    END;

GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  27/03/2020
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCNTagregarAcumuladosContables'))
	DROP PROCEDURE pCNTagregarAcumuladosContables
GO

CREATE PROC [dbo].[pCNTagregarAcumuladosContables]
@IdPeriodoInicial AS INT = 0,
@IdPeriodoFinal AS   INT = 0,
@IdPolizaE AS        INT = 0
AS
BEGIN

    DECLARE @UsaMovimientoIntersucursal AS BIT = ISNULL(( SELECT IIF(Valor = 'true', 1, 0)FROM tCTLconfiguracion WHERE IdConfiguracion = 17 ), 0);
    IF( @IdPolizaE = 0 )
        BEGIN
        PRINT 'todos las posibles cuentas';

        INSERT INTO tCNTacumuladosContables( IdPeriodo, IdCuentaContable, IdCentroCostos, IdSucursal )
        SELECT per.IdPeriodo,
            IdCuentaContable,
            IdCentroCostos,
            IIF(@UsaMovimientoIntersucursal = 0, 0, IdSucursal) AS IdSucursal
        FROM tCNTpolizasR pol
        CROSS APPLY tCTLperiodos per
        WHERE per.IdPeriodo <> 0 AND per.IdPeriodo >= @IdPeriodoInicial AND per.IdPeriodo <= @IdPeriodoFinal
        GROUP BY IdCuentaContable,
            IdCentroCostos,
            IIF(@UsaMovimientoIntersucursal = 0, 0, IdSucursal),
            per.IdPeriodo
        ORDER BY per.IdPeriodo,
            pol.IdCuentaContable,
            pol.IdCentroCostos;
        END;
    ELSE
        BEGIN
        --acumulados contables desde polizasR
        INSERT INTO tCNTacumuladosContables( IdPeriodo, IdCuentaContable, IdCentroCostos, IdSucursal )
        SELECT IdPeriodo,
            IdCuentaContable,
            IdCentroCostos,
            IdSucursal
        FROM
            (   SELECT z.IdPeriodo,
                    z.IdCuentaContable,
                    z.IdCentroCostos,
                    IIF(@UsaMovimientoIntersucursal = 0, 0, z.IdSucursal) AS IdSucursal
                FROM tCNTpolizasR z WITH( NOLOCK )
                WHERE z.IdPolizaE = @IdPolizaE
                GROUP BY z.IdPeriodo,
                    z.IdCuentaContable,
                    z.IdCentroCostos,
                    IIF(@UsaMovimientoIntersucursal = 0, 0, z.IdSucursal)) AS polizaR
        WHERE NOT EXISTS
            (   SELECT IdCuentaContable
                FROM tCNTacumuladosContables tcc
                WHERE tcc.IdPeriodo = polizaR.IdPeriodo AND tcc.IdCuentaContable = polizaR.IdCuentaContable AND tcc.IdCentroCostos = polizaR.IdCentroCostos AND tcc.IdSucursal = polizaR.IdSucursal );

        END;

    --acumulados contables cuentas padres.
    WHILE EXISTS
              (   SELECT TOP 1 a.IdPeriodo
                  FROM tCNTcuentas c
                  INNER JOIN tCNTacumuladosContables a ON c.IdCuentaContable = a.IdCuentaContable
                  LEFT JOIN tCNTacumuladosContables a2 ON a.IdPeriodo = a2.IdPeriodo AND c.IdCuentaContablePadre = a2.IdCuentaContable AND a.IdCentroCostos = a2.IdCentroCostos
                  WHERE c.IdCuentaContablePadre <> 0 AND a2.IdPeriodo IS NULL )
        BEGIN
			INSERT tCNTacumuladosContables( IdPeriodo, IdCuentaContable, IdCentroCostos, IdSucursal )
            SELECT DISTINCT a.IdPeriodo,
                c.IdCuentaContablePadre AS IdCuentaContable,
                a.IdCentroCostos,
                a.IdSucursal
            FROM tCNTcuentas c
            INNER JOIN tCNTacumuladosContables a ON c.IdCuentaContable = a.IdCuentaContable
            LEFT JOIN tCNTacumuladosContables a2 ON a.IdPeriodo = a2.IdPeriodo AND c.IdCuentaContablePadre = a2.IdCuentaContable AND a.IdCentroCostos = a2.IdCentroCostos AND a2.IdSucursal = a.IdSucursal
            WHERE c.IdCuentaContablePadre <> 0 AND a2.IdPeriodo IS NULL;
        END;

    --Revisión de las cuentas que falten
    IF( @IdPolizaE = 0 )
        BEGIN
			INSERT tCNTacumuladosContables( IdPeriodo, IdCuentaContable, IdCentroCostos, IdSucursal )
			SELECT acu.IdPeriodo,
				tc.IdCuentaContablePadre,
				acu.IdCentroCostos,
				acu.IdSucursal
			FROM tCNTacumuladosContables acu
			JOIN tCNTcuentas tc ON tc.IdCuentaContable = acu.IdCuentaContable
			WHERE tc.IdCuentaContablePadre != 0 AND NOT EXISTS
				(   SELECT ex.IdCuentaContable
					FROM tCNTacumuladosContables ex
					WHERE ex.IdPeriodo = acu.IdPeriodo AND ex.IdCuentaContable = tc.IdCuentaContablePadre AND ex.IdCentroCostos = acu.IdCentroCostos AND ex.IdSucursal = acu.IdSucursal );
        END;
    END;
GO



/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  27/03/2020
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCNTactualizarAcumuladosCargosAbonos'))
	DROP PROCEDURE pCNTactualizarAcumuladosCargosAbonos
GO

CREATE PROC [dbo].[pCNTactualizarAcumuladosCargosAbonos]
AS
BEGIN
    PRINT 'ACTUALIZA CARGOS Y ABONOS A CERO';
    PRINT CURRENT_TIMESTAMP;
    DECLARE @UsaMovimientoIntersucursal AS BIT = ISNULL(( SELECT IIF(Valor = 'true', 1, 0)FROM tCTLconfiguracion WHERE IdConfiguracion = 17 ), 0);

    --ACTUALIZA CARGOS Y ABONOS A CERO
    UPDATE acu
    SET Cargo = 0,
        Abono = 0
    FROM tCNTacumuladosContables acu
    INNER JOIN dbo.vCNTperiodosOrdenados p WITH( NOLOCK )ON p.IdPeriodo = acu.IdPeriodo
    WHERE NOT acu.Cargo = 0 AND NOT acu.Abono = 0 AND p.EjercicioIdEstatus <> 7;

    --ACTUALIZA CARGOS Y ABONOS
    UPDATE acu
    SET Cargo = ISNULL(pol.Cargo, 0),
        Abono = ISNULL(pol.Abono, 0)
    FROM tCNTacumuladosContables acu
    INNER JOIN
        (   SELECT r.IdPeriodo,
                r.IdCuentaContable,
                IdCentroCostos,
                IIF(@UsaMovimientoIntersucursal = 0, 0, r.IdSucursal) AS IdSucursal,
                SUM(r.Cargo) AS Cargo,
                SUM(r.Abono) AS Abono
            FROM tCNTpolizasR r WITH( NOLOCK )
            INNER JOIN tCNTpolizasE e WITH( NOLOCK )ON e.IdPolizaE = r.IdPolizaE
            INNER JOIN dbo.vCNTperiodosOrdenados p WITH( NOLOCK )ON p.IdPeriodo = e.IdPeriodo
            WHERE NOT r.IdPolizaE = 0 AND e.IdEstatus = 1 AND p.EjercicioIdEstatus <> 7
            GROUP BY r.IdPeriodo,
                IdCuentaContable,
                IdCentroCostos,
                IIF(@UsaMovimientoIntersucursal = 0, 0, r.IdSucursal)) AS pol ON pol.IdPeriodo = acu.IdPeriodo AND pol.IdCuentaContable = acu.IdCuentaContable AND pol.IdCentroCostos = acu.IdCentroCostos AND pol.IdSucursal = acu.IdSucursal;
END;

GO


/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  27/03/2020
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCNTactualizarAcumuladosResultados'))
	DROP PROCEDURE pCNTactualizarAcumuladosResultados
GO

CREATE PROC [dbo].[pCNTactualizarAcumuladosResultados]
@IdPolizaE AS         INT = 0,
@IdPeriodo AS         INT = 0,
@IdPeriodoAnterior AS INT = 0
AS
BEGIN

IF( @IdPolizaE = 0 )
    BEGIN
		UPDATE ac
		SET SaldoInicial = ISNULL(acu.SaldoFinal, 0)
		FROM tCNTcuentas cta WITH( NOLOCK )
		INNER JOIN tCNTacumuladosContables ac WITH( NOLOCK )ON ac.IdCuentaContable = cta.IdCuentaContable
		INNER JOIN tCTLperiodos p WITH( NOLOCK )ON ac.IdPeriodo = p.IdPeriodo
		INNER JOIN tCTLtiposD td WITH( NOLOCK )ON td.IdTipoD = cta.IdTipoD
		LEFT JOIN
			(   SELECT IdCuentaContable,
					IdCentroCostos,
					IdPeriodoAnterior,
					IdEjercicio,
					SaldoFinal,
					IdPeriodo,
					IdSucursal
				FROM vCNTacumuladosPeriodoAnterior a
				WHERE a.IdPeriodoAnterior = @IdPeriodoAnterior AND a.IdPeriodo = @IdPeriodo ) AS acu ON ac.IdCuentaContable = acu.IdCuentaContable AND ac.IdCentroCostos = acu.IdCentroCostos AND p.IdEjercicio = acu.IdEjercicio AND acu.IdSucursal = ac.IdSucursal
		WHERE ac.IdPeriodo = @IdPeriodo --Activo - Pasivo - Capital
			AND NOT td.IdTipoDPadre IN ( 45, 46, 47 );
    END;
ELSE
    BEGIN
		UPDATE ac
		SET SaldoInicial = ISNULL(acu.SaldoFinal, 0)
		FROM tCNTcuentas cta WITH( NOLOCK )
		INNER JOIN tCNTpolizasR res WITH( NOLOCK )ON cta.IdCuentaContable = res.IdCuentaContable
		INNER JOIN tCNTacumuladosContables ac WITH( NOLOCK )ON ac.IdCuentaContable = cta.IdCuentaContable
		INNER JOIN tCTLperiodos p WITH( NOLOCK )ON ac.IdPeriodo = p.IdPeriodo
		INNER JOIN tCTLtiposD td WITH( NOLOCK )ON td.IdTipoD = cta.IdTipoD
		INNER JOIN
			(   SELECT IdCuentaContable,
					IdCentroCostos,
					IdPeriodoAnterior,
					IdEjercicio,
					SaldoFinal,
					IdPeriodo,
					IdSucursal
				FROM vCNTacumuladosPeriodoAnterior a
				WHERE a.IdPeriodoAnterior = @IdPeriodoAnterior AND a.IdPeriodo = @IdPeriodo ) AS acu ON ac.IdCuentaContable = acu.IdCuentaContable AND ac.IdCentroCostos = acu.IdCentroCostos AND p.IdEjercicio = acu.IdEjercicio AND acu.IdSucursal = ac.IdSucursal
		WHERE ac.IdPeriodo = @IdPeriodo --Activo - Pasivo - Capital
			AND NOT td.IdTipoDPadre IN ( 45, 46, 47 ) AND res.IdPolizaE = @IdPolizaE;
    END;

END;

GO

/* ==========================================
  Por:  David Vázquez Palestino
Fecha:  27/03/2020
=============================================*/
IF EXISTS (SELECT OBJECT_ID FROM SYS.PROCEDURES WHERE OBJECT_ID = OBJECT_ID('pCNTactualizarAcumuladosBalance'))
	DROP PROCEDURE pCNTactualizarAcumuladosBalance
GO

CREATE PROC [dbo].[pCNTactualizarAcumuladosBalance]
    @IdPolizaE AS         INT = 0,
    @IdPeriodo AS         INT = 0,
    @IdPeriodoAnterior AS INT = 0
AS
    BEGIN
    --SET @IdPeriodoAnterior = IIF(@IdPeriodoAnterior = 0, @IdPeriodo - 1, @IdPeriodoAnterior)
    --SET @IdPeriodoAnterior = dbo.fCTLobtenerPeriodoAnterior(@IdPeriodo, 0);

    IF @IdPolizaE = 0
        BEGIN
        --	ACTUALIZA SALDO INICIAL SOLO CUENTAS DE BALANCE.
        UPDATE ac
        SET SaldoInicial = ISNULL(acu.SaldoFinal, 0)
        FROM tCNTcuentas cta WITH( NOLOCK )
        INNER JOIN tCNTacumuladosContables ac WITH( NOLOCK )ON ac.IdCuentaContable = cta.IdCuentaContable
        INNER JOIN tCTLtiposD td WITH( NOLOCK )ON td.IdTipoD = cta.IdTipoD
        LEFT JOIN
            ( SELECT a.IdCuentaContable,
                     a.IdCentroCostos,
                     a.IdPeriodoAnterior,
                     a.IdEjercicio,
                     a.SaldoFinal,
                     a.IdPeriodo,
                     a.IdSucursal FROM vCNTacumuladosPeriodoAnteriorBalance a WHERE a.IdPeriodoAnterior = @IdPeriodoAnterior AND a.IdPeriodo = @IdPeriodo ) AS acu ON ac.IdCuentaContable = acu.IdCuentaContable AND ac.IdCentroCostos = acu.IdCentroCostos AND ac.IdSucursal = acu.IdSucursal
        WHERE ac.IdPeriodo = @IdPeriodo AND td.IdTipoDPadre IN ( 45, 46, 47 );
        END;
    ELSE
        BEGIN
        --	ACTUALIZA SALDO INICIAL SOLO CUENTAS DE BALANCE.
        UPDATE ac
        SET SaldoInicial = ISNULL(acu.SaldoFinal, 0)
        FROM tCNTcuentas cta WITH( NOLOCK )
        INNER JOIN tCNTpolizasR res WITH( NOLOCK )ON res.IdCuentaContable = cta.IdCuentaContable
        INNER JOIN tCNTacumuladosContables ac WITH( NOLOCK )ON ac.IdCuentaContable = cta.IdCuentaContable
        INNER JOIN tCTLtiposD td WITH( NOLOCK )ON td.IdTipoD = cta.IdTipoD
        INNER JOIN
            ( SELECT a.IdCuentaContable,
                     a.IdCentroCostos,
                     a.IdPeriodoAnterior,
                     a.IdEjercicio,
                     a.SaldoFinal,
                     a.IdPeriodo,
                     a.IdSucursal FROM vCNTacumuladosPeriodoAnteriorBalance a WHERE a.IdPeriodoAnterior = @IdPeriodoAnterior AND a.IdPeriodo = @IdPeriodo ) AS acu ON ac.IdCuentaContable = acu.IdCuentaContable AND ac.IdCentroCostos = acu.IdCentroCostos AND ac.IdSucursal = acu.IdSucursal
        WHERE ac.IdPeriodo = @IdPeriodo AND td.IdTipoDPadre IN ( 45, 46, 47 ) --Activo - Pasivo - Capital
            AND res.IdPolizaE = @IdPolizaE;
        END;
    END;
GO

