ALTER FUNCTION [dbo].[fnAYCCalcularInteresReal]( @IdEjercicio INT )
RETURNS TABLE
AS
RETURN
(
    SELECT y.IdCuenta,
           y.Descripcion,
           y.FechaInicial,
           y.FechaFinal,
           y.DiasInversion,
           y.TasaAnual,
           y.TasaDiaria,
           y.MontoInvertido,
           y.SaldoPromedio,
           y.InteresNominal,
           y.Factor,
           InteresReal = IIF(y.InteresNominal < y.Factor, 0, InteresNominal - y.Factor)
    FROM
    (
        SELECT x.IdCuenta,
               x.Descripcion,
               x.FechaInicial,
               x.FechaFinal,
               x.DiasInversion,
               x.TasaAnual,
               x.TasaDiaria,
               x.MontoInvertido,
               x.SaldoPromedio,
               InteresNominal = x.DiasInversion * x.TasaDiaria * x.MontoInvertido,
               Factor = SaldoPromedio * ((x.INPCMAX / x.INPCMIN) - 1)
        FROM
        (
            SELECT Cuenta.IdCuenta,
                   INPC.FechaInicial,
                   INPC.FechaFinal,
                   DiasInversion = DATEDIFF(DAY, INPC.FechaInicial, INPC.FechaFinal),
                   TasaAnual = Cuenta.InteresOrdinarioAnual,
                   TasaDiaria = ROUND(InteresOrdinarioAnual / IIF(Cuenta.DiasTipoAnio = 0, .1, Cuenta.DiasTipoAnio), 4),
                   MontoInvertido = Saldo.Saldo,
                   INPC.INPCMIN,
                   INPC.INPCMAX,
                   INPC.SaldoPromedio,
                   Cuenta.Descripcion
            FROM dbo.tAYCcuentas Cuenta
                INNER JOIN
                (
                    SELECT Cuenta.IdCuenta,
                           Cuenta.FechaInicial,
                           Cuenta.FechaFinal,
                           INPCMIN = MIN(Indicador.Indice),
                           INPCMAX = MAX(Indicador.Indice),
                           SaldoPromedio = SUM(Cuenta.Saldo / IIF(Cuenta.Dias <= 0, .01, Cuenta.Dias))
                    FROM tGRLindicadoresINPC Indicador
                        INNER JOIN
                        (
                            SELECT CuentaAcreedora.IdCuenta,
                                   FechaInicial = MIN(CuentaAcreedora.FechaInicial),
                                   FechaFinal = MAX(CuentaAcreedora.FechaFinal),
                                   Dias = SUM(ISNULL(
                                                        DATEDIFF(
                                                                    DAY,
                                                                    CuentaAcreedora.FechaInicial,
                                                                    CuentaAcreedora.FechaFinal
                                                                ),
                                                        0
                                                    )
                                             ),
                                   Saldo = SUM(ISNULL(Saldo, 0))
                            FROM dbo.tSDOsaldosCuentasAcreedoras CuentaAcreedora
                                INNER JOIN dbo.tSDOhistorialAcreedoras Historial
                                    ON Historial.IdCuenta = CuentaAcreedora.IdCuenta
                                INNER JOIN dbo.tCTLperiodos Periodo
                                    ON Periodo.IdPeriodo = Historial.IdPeriodo
                                INNER JOIN dbo.tCTLejercicios Ejercicio
                                    ON Ejercicio.IdEjercicio = Periodo.IdEjercicio
                            WHERE CuentaAcreedora.Saldo > 0
                                  AND FechaInicial
                                  BETWEEN Ejercicio.Inicio AND Ejercicio.Fin
                                  AND FechaFinal
                                  BETWEEN Ejercicio.Inicio AND Ejercicio.Fin
                                  AND Ejercicio.IdEjercicio = @IdEjercicio
                            GROUP BY CuentaAcreedora.IdCuenta
                        ) Cuenta
                            ON Indicador.FechaPublicacion
                               BETWEEN Cuenta.FechaInicial AND Cuenta.FechaFinal
                    GROUP BY Cuenta.IdCuenta,
                             Cuenta.FechaInicial,
                             Cuenta.FechaFinal
                ) AS INPC
                    ON INPC.IdCuenta = Cuenta.IdCuenta
                INNER JOIN dbo.tSDOsaldosCuentasAcreedoras Saldo
                    ON Saldo.IdCuenta = Cuenta.IdCuenta
                       AND Saldo.FechaInicial = INPC.FechaInicial
        ) AS x
    ) AS y
);





