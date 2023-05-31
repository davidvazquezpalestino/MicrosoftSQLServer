DELETE FROM ##Incidencias
WHERE codigo IS NULL;

INSERT INTO dbo.tNOMfaltasIncapacidades (IdEmpresaNomina, IdEmpleado, IdBienServicio, NumeroFaltas, Inicio, Fin, IdEstatus)
SELECT IdEmpresaNomina = 2,
    Empleado.IdEmpleado,
    IdBienServicio = SUBSTRING (Layout.Incidencia, 0, CHARINDEX ('=', Layout.Incidencia, 0)),
    Layout.Formula,
    Layout.Inicio,
    Layout.Fin,
    IdEstatus = 1
FROM ##Incidencias Layout WITH (NOLOCK)
INNER JOIN dbo.vPERempleados Empleado ON Layout.Codigo = Empleado.Codigo 
WHERE Layout.Codigo IS NOT NULL 

UNION ALL

SELECT IdEmpresaNomina = 3,
    Empleado.IdEmpleado,
    IdBienServicio = SUBSTRING (Layout.Incidencia, 0, CHARINDEX ('=', Layout.Incidencia, 0)),
    Layout.Formula,
    Layout.Inicio,
    Layout.Fin,
    IdEstatus = 1
FROM ##Incidencias Layout WITH (NOLOCK)
INNER JOIN dbo.vPERempleados Empleado ON Layout.Codigo = Empleado.Codigo 
WHERE Layout.Codigo IS NOT NULL 


SELECT IdEmpresaNomina,
    IdEmpleado,
    NumeroFaltas = SUM (NumeroFaltas)
FROM dbo.tNOMfaltasIncapacidades
GROUP BY
    IdEmpresaNomina,
    IdEmpleado
HAVING SUM (NumeroFaltas) > 15;


