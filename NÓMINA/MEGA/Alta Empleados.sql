USE IERP_MGE_NOMINA;
GO


INSERT INTO dbo.tGRLpersonas ( CodigoInterfaz, Nombre, RFC, Alta )
SELECT Tabla.Codigo,
    Nombre = CONCAT (Tabla.Nombre, ' ', Tabla.ApellidoPaterno, ' ', Tabla.ApellidoMaterno),
    Tabla.RFC,
    Alta = CURRENT_TIMESTAMP
FROM ##Empleados Tabla
LEFT JOIN dbo.tPERempleados Per ON Per.Codigo = Tabla.Codigo
WHERE Tabla.Codigo IS NOT NULL AND Per.IdEmpleado IS NULL AND NOT EXISTS ( SELECT 1 FROM dbo.tGRLpersonas p WHERE RFC = Tabla.RFC )
ORDER BY TRY_CAST(Tabla.Codigo AS INT);

INSERT INTO dbo.tCTLrelaciones ( IdTipoDdominio, IdDominio, FechaRegistro )
SELECT IdTipoDdominio = 200,
    Persona.IdPersona,
    Persona.Alta
FROM dbo.tGRLpersonas Persona
WHERE Persona.IdPersona > 1 AND NOT EXISTS ( SELECT 1 FROM dbo.tCTLrelaciones Relacion WHERE IdTipoDdominio = 200 AND Relacion.IdDominio = Persona.IdPersona );

UPDATE Persona
SET Persona.IdRelEmails = Relacion.IdRel
FROM dbo.tGRLpersonas Persona
INNER JOIN dbo.tCTLrelaciones Relacion ON Relacion.IdTipoDdominio = 200 AND Persona.IdPersona = Relacion.IdDominio
WHERE Persona.IdRelEmails = 0;

INSERT INTO dbo.tCATemails ( IdRel, email, IdListaD, EsPrincipal, EsCorporativo, IdTipoDDominio, IdControl )
SELECT Persona.IdRelEmails,
    Tabla.Mail,
    IdListaD = -22,
    EsPrincipal = 1,
    EsCorporativo = 1,
    IdTipoDDominio = 200,
    Persona.IdPersona
FROM ##Empleados Tabla
INNER JOIN dbo.tGRLpersonas Persona ON Persona.CodigoInterfaz = Tabla.Codigo
WHERE Tabla.Mail IS NOT NULL AND NOT EXISTS ( SELECT 1 FROM dbo.tCATemails Correo WHERE IdTipoDDominio = 200 AND Correo.IdControl = Persona.IdPersona );

INSERT INTO dbo.tGRLpersonasFisicas ( IdPersonaFisica, Nombre, ApellidoPaterno, ApellidoMaterno, FechaNacimiento, Sexo, CURP, IdTipoDEstadoCivil, EsEmpleado, IdPersona, NumeroIMMS )
SELECT Persona.IdPersona,
    Tabla.Nombre,
    Tabla.ApellidoPaterno,
    Tabla.ApellidoMaterno,
    Tabla.FechaNacimiento,
    Sexo = CASE Tabla.Genero WHEN 'FEMENINO' THEN 'F'
                             WHEN 'MASCULINO' THEN 'M'
                             ELSE ''
           END,
    Tabla.CURP,
    EstadoCivil.IdTipoD,
    EsEmpleado = 1,
    Persona.IdPersona,
    NumeroIMSS = ISNULL (Tabla.NumeroIMSS, '')
FROM ##Empleados Tabla
INNER JOIN dbo.tGRLpersonas Persona ON Tabla.Codigo = Persona.CodigoInterfaz
LEFT JOIN dbo.tGRLpersonasFisicas PersonaFisica ON PersonaFisica.IdPersona = Persona.IdPersona
LEFT JOIN dbo.tCTLtiposD EstadoCivil ON EstadoCivil.IdTipoE = 33 AND EstadoCivil.Descripcion = CASE Tabla.EstadoCivil WHEN 'SOLTERO' THEN 'SOLTERO/A'
                                                                                                                      WHEN 'CASADO' THEN 'CASADO/A BM'
                                                                                                                      ELSE Tabla.EstadoCivil
                                                                                               END
WHERE PersonaFisica.IdPersonaFisica IS NULL AND NOT EXISTS ( SELECT 1 FROM dbo.tGRLpersonasFisicas PersonaFisica WHERE PersonaFisica.CURP = Tabla.CURP );

INSERT INTO dbo.tPERempleados ( Codigo, FechaIngreso, IdPersonaFisica, NumeroIMSS, RecibePagoNomina, IdAuxiliarSueldo, IdPuesto, IdSucursal, CodigoInterfaz )
SELECT Tabla.Codigo,
    Tabla.FechaIngreso,
    PersonaFisica.IdPersonaFisica,
    NumeroIMSS = ISNULL (CAST(Tabla.NumeroIMSS AS BIGINT), ''),
    RecibePagoNomina = 1,
    IdAuxiliarSueldo = -7,
    IdPuesto = ISNULL (Puesto.IdPuesto, 0),
    IdSucursal = ISNULL (Sucursal.IdSucursal, 0),
    CodigoInterfaz = Persona.CodigoInterfaz
FROM ##Empleados Tabla
INNER JOIN dbo.tGRLpersonas Persona ON Tabla.Codigo = Persona.CodigoInterfaz
INNER JOIN dbo.tGRLpersonasFisicas PersonaFisica ON PersonaFisica.IdPersona = Persona.IdPersona
LEFT JOIN dbo.tPERempleados Empleado ON Persona.CodigoInterfaz = Empleado.Codigo
LEFT JOIN dbo.tPERpuestos Puesto ON Puesto.Descripcion = Tabla.Puesto
LEFT JOIN dbo.tCTLsucursales Sucursal ON Sucursal.Descripcion = Tabla.Sucusal
WHERE Empleado.IdEmpleado IS NULL;


-- actualizamos el idpersona fisica
UPDATE Persona
SET Persona.IdPersonaFisica = Persona.IdPersona
FROM dbo.tPERempleados Empleado
INNER JOIN dbo.tGRLpersonas Persona ON Persona.IdPersona = Empleado.IdPersonaFisica
LEFT JOIN dbo.tGRLpersonasFisicas PersonaFisica ON PersonaFisica.IdPersonaFisica = Persona.IdPersonaFisica
WHERE Empleado.IdEmpleado > 0 AND Persona.IdPersonaFisica = 0;

INSERT INTO dbo.tFELempleados ( IdEmpleado, NumSeguridadSocial, CLABE, SalarioDiario, SalarioBaseCotApor, SalarioDiarioIntegrado, IdTipoDregimen, IdTipoDperiodicidad, IdTipoDcontrato, IdTipoDjornada, IdTipoDriesgoSAT, IdEstadoPrestaServicio )
SELECT PerEmpleado.IdEmpleado,
    PerEmpleado.NumeroIMSS,
    CuentaBancaria = ISNULL (CAST(Tabla.[Cuenta/Clabe] AS BIGINT), ''),
    Tabla.SalarioDiario,
    Tabla.BaseCotizar,
    Tabla.SDI,
    TipoRegimen.IdTipoD,
    TipoPeriodicidad.IdTipoD,
    TipoContrato.IdTipoD,
    TipoJornada.IdTipoD,
    TipoRiesgo.IdTipoD, 
	Estado.IdEstado
FROM dbo.tPERempleados PerEmpleado
INNER JOIN ##Empleados Tabla ON PerEmpleado.Codigo = Tabla.Codigo
LEFT JOIN dbo.tFELempleados FelEmpleado ON FelEmpleado.IdEmpleado = PerEmpleado.IdEmpleado
LEFT JOIN dbo.tCTLtiposD TipoRegimen WITH ( NOLOCK ) ON TipoRegimen.IdTipoE = 98 AND TipoRegimen.Codigo = Tabla.TipoRegimen
LEFT JOIN dbo.tCTLtiposD TipoPeriodicidad WITH ( NOLOCK ) ON TipoPeriodicidad.IdTipoE = 106 AND TipoPeriodicidad.Codigo = Tabla.TipoPeriodicidad
LEFT JOIN dbo.tCTLtiposD TipoContrato WITH ( NOLOCK ) ON TipoContrato.IdTipoE = 104 AND TipoContrato.Codigo = Tabla.TipoContrato
LEFT JOIN dbo.tCTLtiposD TipoJornada WITH ( NOLOCK ) ON TipoJornada.IdTipoE = 105 AND TipoJornada.Codigo = Tabla.TipoJornada
LEFT JOIN dbo.tCTLtiposD TipoRiesgo WITH ( NOLOCK ) ON TipoRiesgo.IdTipoE = 99 AND TipoRiesgo.Codigo = Tabla.TipoRiesgo
LEFT JOIN dbo.tSATbancos banco ON banco.Clave = Tabla.Banco
LEFT JOIN dbo.tCTLestados Estado ON Estado.Descripcion = a.estado
WHERE FelEmpleado.IdEmpleado IS NULL;



INSERT INTO dbo.tNOMempleados ( IdEmpleado, IdEmpresaNomina, IdRegistroPatronal, IdTipoNomina, SalarioDiario, BaseCotizar, SDI, IdTablaESDI, IdTablaEvacaciones, IdMetodoPago, IdTipoDbaseCotizacion, IdEstatus )
SELECT empl.IdEmpleado,
    IdEmpresaNomina = 2,
    IdRegistroPatronal = 1,
    IdTipoNomina = 1,
    SalarioDiario = ROUND (t.SalarioDiario, 6),
    BaseCotizar = ROUND (t.BaseCotizar, 6),
    SDI = ROUND (t.SDI, 6),
    IdTablaESDI = 4,
    IdTablaEvacaciones = 5,
    IdMetodoPago = -3,
    IdTipoDbaseCotizacion = 1981,
    IdEstatus = 1
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleados NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[VISION] = 'SI'
UNION
SELECT empl.IdEmpleado,
    IdEmpresaNomina = 4,
    IdRegistroPatronal = 2,
    IdTipoNomina = 1,
    SalarioDiario = ROUND (t.SalarioDiario, 6),
    BaseCotizar = ROUND (t.BaseCotizar, 6),
    SDI = ROUND (t.SDI, 6),
    IdTablaESDI = 4,
    IdTablaEvacaciones = 5,
    IdMetodoPago = -3,
    IdTipoDbaseCotizacion = 1981,
    IdEstatus = 1
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleados NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[PROCESADORA] = 'SI'
UNION
SELECT empl.IdEmpleado,
    IdEmpresaNomina = 5,
    IdRegistroPatronal = 3,
    IdTipoNomina = 1,
    SalarioDiario = ROUND (t.SalarioDiario, 6),
    BaseCotizar = ROUND (t.BaseCotizar, 6),
    SDI = ROUND (t.SDI, 6),
    IdTablaESDI = 4,
    IdTablaEvacaciones = 5,
    IdMetodoPago = -3,
    IdTipoDbaseCotizacion = 1981,
    IdEstatus = 1
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleados NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[GRUPO BUEN ORO] = 'SI'
UNION
SELECT empl.IdEmpleado,
    IdEmpresaNomina = 3,
    IdRegistroPatronal = 0,
    IdTipoNomina = 1,
    SalarioDiario = ROUND ([SD END], 6),
    BaseCotizar = 0,
    SDI = 0,
    IdTablaESDI = 4,
    IdTablaEvacaciones = 5,
    IdMetodoPago = -3,
    IdTipoDbaseCotizacion = 1981,
    IdEstatus = 1
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleados NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[ENEDE] = 'SI';

INSERT INTO dbo.tNOMempleadosSalarios ( IdEmpleado, IdEmpresaNomina, FechaInicio, FechaFin, SalarioDiario, BaseCotizar, SDI )
SELECT empl.IdEmpleado,
    IdEmpresa = 2,
    FechaInicio = empl.FechaIngreso,
    FechaFin = '1900-01-01',
    SalarioDiario = ROUND (t.SalarioDiario, 6),
    BaseCotizar = ROUND (t.BaseCotizar, 6),
    SDI = ROUND (t.SDI, 6)
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleadosSalarios NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[VISION] = 'SI'
UNION

SELECT empl.IdEmpleado,
    IdEmpresa = 4,
    FechaInicio = empl.FechaIngreso,
    FechaFin = '1900-01-01',
    SalarioDiario = ROUND (t.SalarioDiario, 6),
    BaseCotizar = ROUND (t.BaseCotizar, 6),
    SDI = ROUND (t.SDI, 6)
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleadosSalarios NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[PROCESADORA] = 'SI'
UNION

SELECT empl.IdEmpleado,
    IdEmpresa = 5,
    FechaInicio = empl.FechaIngreso,
    FechaFin = '1900-01-01',
    SalarioDiario = ROUND (t.SalarioDiario, 6),
    BaseCotizar = ROUND (t.BaseCotizar, 6),
    SDI = ROUND (t.SDI, 6)
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleadosSalarios NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[GRUPO BUEN ORO] = 'SI'

UNION
SELECT empl.IdEmpleado,
    IdEmpresa = 3,
    FechaInicio = empl.FechaIngreso,
    FechaFin = '1900-01-01',
    ROUND (t.[SD END] , 6),
    0,
    0
FROM ##Empleados t
INNER JOIN dbo.tPERempleados empl ON empl.Codigo = t.Codigo
LEFT JOIN dbo.tNOMempleadosSalarios NomEmp ON NomEmp.IdEmpleado = empl.IdEmpleado
WHERE NomEmp.IdEmpleado IS NULL AND t.[ENEDE] = 'SI';

DISABLE TRIGGER dbo.trEstatusActualBitacoraEstatus ON dbo.tCTLestatusActual;

BEGIN
    INSERT INTO dbo.tCTLestatusActual ( IdEstatus, Alta, IdTipoDDominio, IdControl )
    SELECT 1 AS IdEstatus,
        CURRENT_TIMESTAMP Alta,
        236 AS IdTipoDDominio,
        IdEmpleado AS IdControl
    FROM dbo.tPERempleados emp
    WHERE IdEstatusActual = 0 AND NOT EXISTS ( SELECT IdControl FROM dbo.tCTLestatusActual e WHERE IdTipoDDominio = 236 AND e.IdEstatusActual = emp.IdEstatusActual );

    UPDATE dom
    SET IdEstatusActual = ea.IdEstatusActual
    FROM dbo.tPERempleados dom
    INNER JOIN dbo.tCTLestatusActual ea ON dom.IdEmpleado = ea.IdControl AND ea.IdTipoDDominio = 236
    WHERE dom.IdEstatusActual = 0 AND ea.IdControl <> 0;
END;

ENABLE TRIGGER dbo.trEstatusActualBitacoraEstatus ON dbo.tCTLestatusActual;


