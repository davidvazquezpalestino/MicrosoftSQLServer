DECLARE @IdEmpresaNomina INT = 3;

DROP TABLE IF EXISTS #Incidencias;

CREATE TABLE #Incidencias
(
IdEmpresaNomina INT NULL,
IdPeriodoNomina INT NULL,
IdEmpleado INT NULL,
IdBienServicio VARCHAR(MAX) NULL,
Formula VARCHAR(254) NULL
);

INSERT INTO #Incidencias ( IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Formula )
SELECT NomEmpleado.IdEmpresaNomina,
       IdPeriodoNomina = Periodo.IdPeriodoNomina,
       Empleado.IdEmpleado,
       Tabla.IdBienServicio,
       Tabla.Formula
FROM dbo.tNOMempleados NomEmpleado
INNER JOIN dbo.tPERempleados Empleado WITH ( NOLOCK ) ON Empleado.IdEmpleado = NomEmpleado.IdEmpleado
INNER JOIN
( SELECT Inc.Codigo,
         Inc.Periodo,
         Inc.Formula,
         Bien.IdBienServicio
  FROM ##Incidencias Inc WITH ( NOLOCK )
  LEFT JOIN dbo.tGRLbienesServicios Bien ON Bien.Codigo = Inc.Incidencia
  WHERE Inc.Codigo IS NOT NULL AND Inc.Formula <> '' ) AS Tabla ON Empleado.Codigo COLLATE DATABASE_DEFAULT = CAST(Tabla.Codigo AS VARCHAR(100)) COLLATE DATABASE_DEFAULT
INNER JOIN dbo.tNOMperiodos Periodo WITH ( NOLOCK ) ON Periodo.Codigo COLLATE DATABASE_DEFAULT = Tabla.Periodo COLLATE DATABASE_DEFAULT
INNER JOIN dbo.tNOMempresas Empresa ON Empresa.IdEmpresa = Periodo.IdEmpresaNomina AND NomEmpleado.IdEmpresaNomina = Empresa.IdEmpresa
WHERE Periodo.IdEstatus = 1 AND Empresa.IdEmpresa = @IdEmpresaNomina;

INSERT INTO dbo.tNOMincidencias ( IdEmpresaNomina, IdPeriodoNomina, IdEmpleado, IdBienServicio, Valor )
SELECT IdEmpresaNomina,
       IdPeriodoNomina,
       IdEmpleado,
       IdBienServicio,
       Formula
FROM #Incidencias tmp
WHERE NOT EXISTS
( SELECT 1
  FROM dbo.tNOMincidencias inc
  WHERE tmp.IdEmpleado = inc.IdEmpleado AND tmp.IdPeriodoNomina = inc.IdPeriodoNomina AND inc.IdBienServicio = tmp.IdBienServicio );
