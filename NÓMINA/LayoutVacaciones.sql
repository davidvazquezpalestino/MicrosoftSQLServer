INSERT INTO dbo.tNOMvacaciones (IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Aniversario, PrimaVacacional, FechaInicio, FechaFin, Dias, IdEstatus)


SELECT Empleado.IdEmpresaNomina,
    Periodo.IdPeriodoNomina,
    Empleado.IdEmpleado,
    IdBienServicio = -1178,
    Aniversario = 0,
    PrimaVacacional = 0,
    Periodo.Inicio,
    Periodo.Fin,
    Tabla.Formula,
    IdEstatus = 1
FROM dbo.vNOMempleados Empleado
INNER JOIN ##Incidencias Tabla ON Empleado.Codigo = Tabla.Codigo
INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdTipoNomina = Empleado.IdTipoNomina AND Tabla.Periodo = Periodo.Codigo
LEFT JOIN dbo.tNOMvacaciones Vacacion ON Vacacion.IdPeriodoNomina = Periodo.IdPeriodoNomina AND Vacacion.IdBienServicio = -1178 AND Vacacion.IdEmpleado = Empleado.IdEmpleado
WHERE Vacacion.IdBienServicio IS NULL;

