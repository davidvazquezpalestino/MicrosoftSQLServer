BEGIN TRANSACTION;

DECLARE @IdEmpresaNomina INT = 3;

DELETE FROM ##Incidencias
WHERE Codigo IS NULL;

DROP TABLE IF EXISTS #programacion;

CREATE TABLE #programacion
(
IdEmpresaNomina INT NULL,
Codigo INT NULL,
IdTipoD VARCHAR(MAX) NULL,
IdPeriodoNomina INT NULL,
IdEmpleado INT NULL,
IdBienServicio VARCHAR(MAX) NULL,
Inicio DATE NULL,
Fin DATE NULL,
Formula VARCHAR(254) NULL,
IdEstatus INT NULL
);

DROP TABLE IF EXISTS #Excepciones;

CREATE TABLE #Excepciones
(
Periodo VARCHAR(32) NULL,
Codigo VARCHAR(32) NULL,
Nombre VARCHAR(254) NULL,
Mensaje VARCHAR(1024) NULL
);

INSERT INTO #programacion (IdEmpresaNomina,  IdTipoD, IdPeriodoNomina, IdEmpleado, IdBienServicio, Inicio, Fin, Formula, IdEstatus)
SELECT NomEmpleado.IdEmpresaNomina,
    Incidencia.IdTipoD,
    IdPeriodoNomina = IIF(Incidencia.IdBienServicio IN (-1107, -1157), 0, Periodo.IdPeriodoNomina),
    Empleado.IdEmpleado,
    Incidencia.IdBienServicio,
    Periodo.Inicio,
    Fin = IIF(Incidencia.IdTipoD = 1964, NULL, Periodo.Fin),
    Incidencia.Formula,
    IdEstatus = 1
FROM dbo.tNOMempleados NomEmpleado
INNER JOIN dbo.tPERempleados Empleado WITH (NOLOCK) ON Empleado.IdEmpleado = NomEmpleado.IdEmpleado
INNER JOIN (SELECT Codigo,
                Periodo,
                Formula,
                IdTipoD = SUBSTRING (Programacion, 0, CHARINDEX ('=', Programacion, 0)),
                IdBienServicio = SUBSTRING (Incidencia, 0, CHARINDEX ('=', Incidencia, 0))
            FROM ##Incidencias WITH (NOLOCK)
            WHERE Codigo IS NOT NULL AND Formula <> '') AS Incidencia ON Empleado.Codigo COLLATE DATABASE_DEFAULT = CAST(Incidencia.Codigo AS VARCHAR(100)) COLLATE DATABASE_DEFAULT
INNER JOIN dbo.tNOMperiodos Periodo WITH (NOLOCK) ON Periodo.Codigo COLLATE DATABASE_DEFAULT = Incidencia.Periodo COLLATE DATABASE_DEFAULT
INNER JOIN dbo.tNOMtiposNominas TipoNomina WITH (NOLOCK) ON TipoNomina.IdTipoNomina = NomEmpleado.IdTipoNomina AND TipoNomina.IdTipoNomina = Periodo.IdTipoNomina
INNER JOIN dbo.tNOMempresas Empresa ON Empresa.IdEmpresa = Periodo.IdEmpresaNomina AND NomEmpleado.IdEmpresaNomina = Empresa.IdEmpresa
WHERE Periodo.IdEstatus = 1 AND Empresa.IdEmpresa = 3 AND NOT EXISTS (SELECT 1
                                                                      FROM dbo.tNOMprogramacion Programacion
                                                                      WHERE Programacion.IdEmpleado = NomEmpleado.IdEmpleado AND Programacion.IdPeriodoNomina = Periodo.IdPeriodoNomina AND Incidencia.IdBienServicio = Programacion.IdBienServicio AND NomEmpleado.IdEmpresaNomina = Empresa.IdEmpresa);

INSERT INTO #Excepciones (Periodo, Codigo, Nombre, Mensaje)
SELECT Periodo.Codigo,
    Empleado.Codigo,
    Empleado.Nombre,
    Mensaje = CONCAT ('No Existe empleado ', Programacion.Codigo)
FROM #programacion Programacion
INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = Programacion.IdPeriodoNomina
LEFT JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = Programacion.IdEmpleado
WHERE Empleado.IdEmpleado IS NULL;

INSERT INTO #Excepciones (Periodo, Codigo, Nombre, Mensaje)
SELECT Periodo.Codigo,
    Empleado.Codigo,
    Empleado.Nombre,
    Mensaje = 'El empleado ya se dio de baja'
FROM #programacion Programacion
INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = Programacion.IdEmpleado
INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = Programacion.IdPeriodoNomina
WHERE Empleado.IdEstatus = 2;

INSERT INTO #Excepciones (Periodo, Codigo, Nombre, Mensaje)
SELECT Periodo.Codigo,
    Empleado.Codigo,
    Empleado.Nombre,
    Mensaje = 'El empleado está repetido en la plantilla de excel'
FROM (SELECT IdEmpleado,
          IdPeriodoNomina,
          IdBienServicio,
          Repetidos = COUNT (IdEmpleado)
      FROM #programacion
      GROUP BY
          IdEmpleado,
          IdPeriodoNomina,
          IdBienServicio
      HAVING COUNT (IdEmpleado) > 1) AS Programacion
INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = Programacion.IdEmpleado
INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = Programacion.IdPeriodoNomina;

INSERT INTO #Excepciones (Periodo, Codigo, Nombre, Mensaje)
SELECT Periodo.Codigo,
    Empleado.Codigo,
    Empleado.Nombre,
    Mensaje = CONCAT ('El empleado ya se encuentra en el período ', Periodo.Codigo)
FROM (SELECT Programacion.IdEmpresaNomina,
          Programacion.IdEmpleado,
          Programacion.IdPeriodoNomina,
          Programacion.IdBienServicio,
          Repetidos = COUNT (Programacion.IdEmpleado)
      FROM dbo.tNOMprogramacion Programacion
      INNER JOIN #programacion tmp ON tmp.IdEmpleado = Programacion.IdEmpleado AND tmp.IdPeriodoNomina = Programacion.IdPeriodoNomina AND tmp.IdBienServicio = Programacion.IdBienServicio AND Programacion.IdEmpresaNomina = 3
      GROUP BY
          Programacion.IdEmpresaNomina,
          Programacion.IdEmpleado,
          Programacion.IdPeriodoNomina,
          Programacion.IdBienServicio) AS Programacion
INNER JOIN dbo.vPERempleados Empleado ON Empleado.IdEmpleado = Programacion.IdEmpleado
INNER JOIN dbo.tNOMperiodos Periodo ON Periodo.IdPeriodoNomina = Programacion.IdPeriodoNomina;

IF EXISTS (SELECT 1
           FROM #Excepciones
           WHERE Mensaje <> '')
BEGIN
    SELECT Periodo,
        Codigo,
        Nombre,
        Mensaje
    FROM #Excepciones;


    RETURN;
END;

INSERT INTO dbo.tNOMprogramacion (Codigo, IdEmpresaNomina, IdTipoD, IdPeriodoNomina, IdEmpleado, IdBienServicio, FechaInicio, FechaFin, Formula, IdEstatus)
SELECT Codigo,
    @IdEmpresaNomina,
    IdTipoD,
    IdPeriodoNomina,
    IdEmpleado,
    IdBienServicio,
    Inicio,
    Fin,
    Formula,
    IdEstatus
FROM #programacion;

SELECT Programacion.IdProgramacion,
    Programacion.IdEmpresaNomina,
    Programacion.Codigo,
    Programacion.IdTipoD,
    Programacion.IdPeriodoNomina,
    Programacion.IdEmpleado,
    Programacion.IdBienServicio,
    Programacion.FechaInicio,
    Programacion.FechaFin,
    Programacion.Formula,
    Programacion.IdEstatus
FROM dbo.tNOMprogramacion Programacion
INNER JOIN #programacion tmp ON tmp.IdEmpleado = Programacion.IdEmpleado AND Programacion.FechaInicio = tmp.Inicio AND tmp.IdBienServicio = Programacion.IdBienServicio;
GO

ROLLBACK TRANSACTION;