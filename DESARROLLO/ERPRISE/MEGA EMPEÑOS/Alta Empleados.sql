USE IERP_MGE_NOMINA;
GO

INSERT INTO dbo.tGRLpersonas ( CodigoInterfaz, Nombre, RFC, Alta )
SELECT t.Codigo,
       Nombre = CONCAT (t.Nombre, ' ', t.ApellidoPaterno, ' ', t.ApellidoMaterno),
       t.RFC,
       Alta = CURRENT_TIMESTAMP
FROM ##Empleados t
LEFT JOIN dbo.tPERempleados Per ON Per.Codigo = t.Codigo
WHERE t.Codigo IS NOT NULL AND Per.IdEmpleado IS NULL AND NOT EXISTS
( SELECT 1
  FROM dbo.tGRLpersonas p
  WHERE RFC = t.RFC );

INSERT INTO dbo.tGRLpersonasFisicas ( IdPersonaFisica, Nombre, ApellidoPaterno, ApellidoMaterno, FechaNacimiento, Sexo, CURP, IdTipoDEstadoCivil, EsEmpleado, IdPersona, NumeroIMMS )
SELECT Persona.IdPersona,
       t.Nombre,
       t.ApellidoPaterno,
       t.ApellidoMaterno,
       t.FechaNacimiento,
       Sexo = t.Genero,
       t.CURP,
       EstadoCivil.IdTipoD,
       EsEmpleado = 1,
       Persona.IdPersona,
       NumeroIMSS = ISNULL (t.NumeroIMSS, '')
FROM ##Empleados t
INNER JOIN dbo.tGRLpersonas Persona ON t.Codigo = Persona.CodigoInterfaz
LEFT JOIN dbo.tGRLpersonasFisicas PersonaF ON PersonaF.IdPersona = Persona.IdPersona
LEFT JOIN dbo.tCTLtiposD EstadoCivil ON EstadoCivil.IdTipoE = 33 AND EstadoCivil.Descripcion = CASE t.EstadoCivil WHEN 'SOLTERO' THEN
                                                                                                                       'SOLTERO/A'
                                                                                                                  WHEN 'CASADO' THEN
                                                                                                                       'CASADO/A BM'
                                                                                                                  ELSE t.EstadoCivil
                                                                                               END
WHERE PersonaF.IdPersonaFisica IS NULL AND NOT EXISTS
( SELECT 1
  FROM dbo.tGRLpersonasFisicas PersonaFisica
  WHERE PersonaFisica.CURP = t.CURP );

INSERT INTO dbo.tPERempleados ( Codigo, FechaIngreso, IdPersonaFisica, NumeroIMSS, RecibePagoNomina, IdAuxiliarSueldo, IdPuesto, IdSucursal, CodigoInterfaz )
SELECT t.Codigo,
       t.FechaIngreso,
       PersonaF.IdPersonaFisica,
       NumeroIMSS = ISNULL (t.NumeroIMSS, ''),
       RecibePagoNomina = 1,
       IdAuxiliarSueldo = -7,
      IdPuesto = ISNULL(Puesto.IdPuesto, 0) ,
       IdSucursal = ISNULL(Sucursal.IdSucursal, 0),
       CodigoInterfaz = Persona.CodigoInterfaz
FROM ##Empleados t
INNER JOIN dbo.tGRLpersonas Persona ON t.Codigo = Persona.CodigoInterfaz
INNER JOIN dbo.tGRLpersonasFisicas PersonaF ON PersonaF.IdPersona = Persona.IdPersona
LEFT JOIN dbo.tPERempleados Empleado ON Persona.CodigoInterfaz = Empleado.Codigo
LEFT JOIN dbo.tPERpuestos Puesto ON Puesto.Descripcion = t.Puesto
LEFT JOIN dbo.tCTLsucursales Sucursal ON Sucursal.Descripcion = t.Sucusal
WHERE Empleado.IdEmpleado IS NULL;

-- actualizamos el idpersona fisica
SELECT *
-- UPDATE Persona SET Persona.IdPersonaFisica = Persona.IdPersona
FROM dbo.tPERempleados Empleado
INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersona = Empleado.IdPersonaFisica
LEFT JOIN dbo.tGRLpersonasFisicas PersonaFisica ON PersonaFisica.IdPersonaFisica = Persona.IdPersonaFisica
WHERE Empleado.IdEmpleado > 0 AND Persona.IdPersonaFisica = 0;

INSERT INTO dbo.tFELempleados ( IdEmpleado, CLABE, SalarioDiario, SalarioBaseCotApor, SalarioDiarioIntegrado, IdTipoDregimen, IdTipoDperiodicidad, IdTipoDcontrato, IdTipoDjornada, IdTipoDriesgoSAT )
SELECT per.IdEmpleado,
       CuentaBancaria = ISNULL (t.[Cuenta/Clabe], ''),
       t.SalarioDiario,
       t.BaseCotizar,
       t.SDI,
       TipoRegimen.IdTipoD,
       TipoPeriodicidad.IdTipoD,
       TipoContrato.IdTipoD,
       TipoJornada.IdTipoD,
       TipoRiesgo.IdTipoD
FROM dbo.tPERempleados per
INNER JOIN ##Empleados t ON per.Codigo = t.Codigo
LEFT JOIN dbo.tFELempleados emp ON emp.IdEmpleado = per.IdEmpleado
LEFT JOIN dbo.tCTLtiposD TipoRegimen WITH ( NOLOCK ) ON TipoRegimen.IdTipoE = 98 AND TipoRegimen.Codigo = t.TipoRegimen
LEFT JOIN dbo.tCTLtiposD TipoPeriodicidad WITH ( NOLOCK ) ON TipoPeriodicidad.IdTipoE = 106 AND TipoPeriodicidad.Codigo = t.TipoPeriodicidad
LEFT JOIN dbo.tCTLtiposD TipoContrato WITH ( NOLOCK ) ON TipoContrato.IdTipoE = 104 AND TipoContrato.Codigo = t.TipoContrato
LEFT JOIN dbo.tCTLtiposD TipoJornada WITH ( NOLOCK ) ON TipoJornada.IdTipoE = 105 AND TipoJornada.Codigo = t.TipoJornada
LEFT JOIN dbo.tCTLtiposD TipoRiesgo WITH ( NOLOCK ) ON TipoRiesgo.IdTipoE = 99 AND TipoRiesgo.Codigo = t.TipoRiesgo
LEFT JOIN dbo.tSATbancos banco ON banco.Clave = t.Banco
WHERE emp.IdEmpleado IS NULL;

INSERT INTO dbo.tNOMempleados ( IdEmpleado, IdEmpresaNomina, IdRegistroPatronal, IdTipoNomina, SalarioDiario, BaseCotizar, SDI, IdTablaESDI, IdTablaEvacaciones, IdMetodoPago, IdTipoDbaseCotizacion )
SELECT empl.IdEmpleado,
       IdEmpresaNomina = 2,
       IdRegistroPatronal = 1,
       IdTipoNomina = 1,
       t.SalarioDiario,
       t.BaseCotizar,
       t.SDI,
       IdTablaESDI = 4,
       IdTablaEvacaciones = 5,
       IdMetodoPago = -3,
       IdTipoDbaseCotizacion = 1981
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleados NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL
UNION
SELECT empl.IdEmpleado,
       IdEmpresaNomina = 3,
       IdRegistroPatronal = 0,
       IdTipoNomina = 1,
       t.SalarioDiario,
       t.BaseCotizar,
       t.SDI,
       IdTablaESDI = 4,
       IdTablaEvacaciones = 5,
       IdMetodoPago = -3,
       IdTipoDbaseCotizacion = 1981
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleados NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL;

INSERT INTO dbo.tNOMempleadosSalarios ( IdEmpleado, IdEmpresaNomina, FechaInicio, FechaFin, SalarioDiario, BaseCotizar, SDI )
SELECT empl.IdEmpleado,
       IdEmpresa = 2,
       FechaInicio = empl.FechaIngreso,
       FechaFin = '1900-01-01',
       t.SalarioDiario,
       t.BaseCotizar,
       t.SDI
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleadosSalarios NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL
UNION
SELECT empl.IdEmpleado,
       IdEmpresa = 3,
       FechaInicio = empl.FechaIngreso,
       FechaFin = '1900-01-01',
       t.[SD END],
       0,
       0
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleadosSalarios NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL;

DISABLE TRIGGER dbo.trEstatusActualBitacoraEstatus ON dbo.tCTLestatusActual;

BEGIN
    INSERT INTO dbo.tCTLestatusActual ( IdEstatus, Alta, IdTipoDDominio, IdControl )
    SELECT 1 AS IdEstatus,
           CURRENT_TIMESTAMP Alta,
           236 AS IdTipoDDominio,
           IdEmpleado AS IdControl
    FROM dbo.tPERempleados emp
    WHERE IdEstatusActual = 0 AND NOT EXISTS
    ( SELECT IdControl
      FROM dbo.tCTLestatusActual e
      WHERE IdTipoDDominio = 236 AND e.IdEstatusActual = emp.IdEstatusActual );

    UPDATE dom
    SET IdEstatusActual = ea.IdEstatusActual
    FROM dbo.tPERempleados dom
    INNER JOIN dbo.tCTLestatusActual ea ON dom.IdEmpleado = ea.IdControl AND ea.IdTipoDDominio = 236
    WHERE dom.IdEstatusActual = 0 AND ea.IdControl <> 0;
END;

ENABLE TRIGGER dbo.trEstatusActualBitacoraEstatus ON dbo.tCTLestatusActual;
