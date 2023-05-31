SELECT *
-- UPDATE sd SET sd.SDAUX = x.SalarioDiario
FROM dbo.tNOMempleadosSalarios sd
INNER JOIN
( SELECT sd.IdEmpleadoSalario,
         IdEmpleado,
        SalarioDiario = sd.SalarioDiario
  FROM dbo.tNOMempleadosSalarios sd
  WHERE IdEmpresaNomina IN ( 2, 4, 5) AND FechaFin = '19000101' ) AS x ON x.IdEmpleado = sd.IdEmpleado
WHERE sd.IdEmpresaNomina = 3 AND sd.SDAUX <> x.SalarioDiario AND sd.FechaFin = '19000101';


