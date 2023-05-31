TRUNCATE TABLE dbo.tNOMacumulados;

TRUNCATE TABLE dbo.tNOMacumuladosE;

INSERT INTO dbo.tNOMacumulados ( IdEmpresaNomina, IdEjercicio, IdPeriodoNomina, IdEmpleado, IdBienServicio, Inicial, Cantidad, Final, IdTipoNomina )
SELECT CalculoE.IdEmpresaNomina,
       Periodo.IdEjercicio,
       Calculo.IdPeriodoNomina,
       Calculo.IdEmpleado,
       Calculo.IdBienServicio,
       Inicial = ISNULL (SUM (Calculo.Valor) OVER ( PARTITION BY Periodo.IdEjercicio,
                                                                 CalculoE.IdEmpresaNomina,
                                                                 Calculo.IdEmpleado,
                                                                 Calculo.IdBienServicio
                                                    ORDER BY CalculoE.IdEmpresaNomina,
                                                             Calculo.IdEmpleado,
                                                             Periodo.Inicio,
                                                             Calculo.IdBienServicio
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING ), 0),
       Calculo.Valor,
       Final = SUM (Calculo.Valor) OVER ( PARTITION BY Periodo.IdEjercicio,
                                                       CalculoE.IdEmpresaNomina,
                                                       Calculo.IdEmpleado,
                                                       Calculo.IdBienServicio
                                          ORDER BY CalculoE.IdEmpresaNomina,
                                                   Calculo.IdEmpleado,
                                                   Periodo.Inicio,
                                                   Calculo.IdBienServicio
                                          ROWS BETWEEN UNBOUNDED PRECEDING AND 0 PRECEDING ),
       CalculoE.IdTipoNomina
FROM dbo.tNOMcalculosE CalculoE
INNER JOIN dbo.tNOMcalculos Calculo ON Calculo.IdCalculoE = CalculoE.IdCalculoE
INNER JOIN dbo.tNOMperiodosNomina Periodo ON Periodo.IdPeriodoNomina = CalculoE.IdPeriodoNomina
INNER JOIN dbo.tGRLbienesServicios Bien ON Bien.IdBienServicio = Calculo.IdBienServicio
WHERE CalculoE.IdEstatus = 7
      AND Calculo.IdBienServicio IN (-1003, -1001)
	  AND CalculoE.IdTipoNomina = 1;

INSERT INTO dbo.tNOMacumuladosE ( IdEmpresaNomina, IdEjercicio, IdEmpleado, IdBienServicio, Acumulado, IdSesion )
SELECT IdEmpresaNomina,
       IdEjercicio,
       IdEmpleado,
       IdBienServicio,
       Acumulado = SUM (Cantidad),
       IdSesion = 0
FROM dbo.tNOMacumulados
GROUP BY IdEmpresaNomina,
         IdEjercicio,
         IdEmpleado,
         IdBienServicio;

SELECT *
FROM dbo.tNOMacumuladosE
WHERE IdEmpresaNomina = 2
      AND IdEjercicio = 2021
      AND IdEmpleado = 6;

SELECT *
FROM dbo.tNOMacumulados
WHERE IdEmpresaNomina = 2
      AND IdEjercicio = 2021
      AND IdEmpleado = 6;

