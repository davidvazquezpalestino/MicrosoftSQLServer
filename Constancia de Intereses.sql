DECLARE @Inicio AS DATE;
DECLARE @Fin AS DATE;
DECLARE @IdEjercicio INT = 0;
DECLARE @Ejercicio VARCHAR(12) = '2021';

SELECT @IdEjercicio = IdEjercicio,
       @Inicio = Inicio,
       @Fin = Fin
FROM tCTLejercicios
WHERE Codigo = @Ejercicio;

DECLARE @SalariosMinimos AS TABLE
(
    IdSalario INT,
    IdEjercicio INT,
    Inicio DATE,
    Fin DATE,
    Salario DECIMAL(18, 2)
);

DECLARE @UMA AS TABLE
(
    IdUMA INT,
    IdEjercicio INT,
    Inicio DATE,
    Fin DATE,
    UMA DECIMAL(18, 2)
);

INSERT INTO @UMA (IdUMA, IdEjercicio, Inicio, Fin, UMA)
SELECT TOP 1 tablaUMA.IdUMA,
             Ejercicio.IdEjercicio,
             tablaUMA.Inicio,
             tablaUMA.Fin,
             tablaUMA.UMA
FROM dbo.tTBLumas tablaUMA
INNER JOIN dbo.tCTLejercicios Ejercicio ON tablaUMA.Inicio BETWEEN Ejercicio.Inicio AND Ejercicio.Fin
WHERE Ejercicio.Codigo = @Ejercicio
ORDER BY Ejercicio.Inicio DESC;

DECLARE @InteresesPagados AS TABLE
(
    IdSocio INT,
    InteresPagado NUMERIC(18, 2),
    RetencionISR NUMERIC(18, 2),
    Inicio DATE,
    Fin DATE
);

INSERT INTO @InteresesPagados (IdSocio, InteresPagado, RetencionISR, Inicio, Fin)
SELECT cuenta.IdSocio,
       InteresPagado = SUM (ISNULL (tFinanciera.InteresOrdinarioPagado, 2)),
       RetencionISR = SUM (ROUND (ISNULL (tFinanciera.RetencionISR, 0), 2)),
       Inicio = MIN (tFinanciera.Fecha),
       Fin = MAX (tFinanciera.Fecha)
FROM dbo.tSDOtransaccionesFinancieras tFinanciera
INNER JOIN dbo.tAYCcuentas cuenta ON tFinanciera.IdOperacion > 0 AND
                                      cuenta.IdCuenta = tFinanciera.IdCuenta AND
                                      tFinanciera.Fecha BETWEEN @Inicio AND @Fin AND
                                      tFinanciera.IdEstatus = 1
WHERE cuenta.IdTipoDProducto <> 143 AND
    ISNULL (tFinanciera.InteresOrdinarioPagado, 0) > 0
GROUP BY cuenta.IdSocio;

UPDATE interes
SET interes.Inicio = movimientos.Fecha
FROM @InteresesPagados interes
INNER JOIN (   SELECT cuenta.IdSocio,
                      Fecha = MIN (tfinanciera.Fecha)
               FROM dbo.tSDOtransaccionesFinancieras tfinanciera
               INNER JOIN dbo.tAYCcuentas cuenta ON tfinanciera.IdOperacion > 0 AND
                                                     cuenta.IdCuenta = tfinanciera.IdCuenta AND
                                                     cuenta.IdTipoDProducto IN (144, 398) AND
                                                     tfinanciera.IdTipoSubOperacion = 500 AND
                                                     tfinanciera.IdEstatus = 1 AND
                                                     cuenta.InteresOrdinarioAnual > 0
               WHERE tfinanciera.Fecha BETWEEN @Inicio AND @Fin
               GROUP BY cuenta.IdSocio) AS movimientos ON movimientos.IdSocio = interes.IdSocio;

DROP TABLE dbo.#tabla;

CREATE TABLE dbo.#tabla
(
    RFC VARCHAR(30),
    CURP VARCHAR(30),
    [MesInicial] VARCHAR(2),
    [MesFinal] VARCHAR(2),
    [Socio] VARCHAR(300),
    [InteresPagado] NUMERIC(18, 2),
    [InteresReal] NUMERIC(18, 2),
    [InteresExento] NUMERIC(18, 2),
    [ISRretenido] NUMERIC(18, 2),
    [InteresNominal] NUMERIC(18, 2),
    IdSocio INT
);

INSERT INTO #tabla
SELECT [RFC] = per.RFC,
       [CURP] = ISNULL (pf.CURP, ''),
       [MesInicial] = REPLACE (STR (MONTH (MIN (interesPagado.Inicio)), 2), ' ', '0'),
       [MesFinal] = REPLACE (STR (MONTH (MAX (interesPagado.Fin)), 2), ' ', '0'),
       per.Nombre,
       [Monto de interés nominal] = interesPagado.InteresPagado,
       [Interes Real] = SUM (ISNULL (InteresReal.InteresReal, 2)),
       [InteresExento] = (365 * 5 * uma.UMA),
       [ISR retenido] = ISNULL (interesPagado.RetencionISR, 2),
       InteresNominal = ISNULL (interesPagado.InteresPagado, 2),
       s.IdSocio
FROM dbo.tSCSsocios s WITH (NOLOCK)
JOIN dbo.tGRLpersonas per WITH (NOLOCK) ON per.IdPersona = s.IdPersona
LEFT JOIN dbo.tGRLpersonasFisicas pf WITH (NOLOCK) ON pf.IdPersonaFisica = per.IdPersonaFisica
LEFT JOIN dbo.tGRLpersonasMorales pm WITH (NOLOCK) ON pm.IdPersonaMoral = per.IdPersonaMoral
LEFT JOIN dbo.fnAYCCalcularInteresReal (@IdEjercicio) AS InteresReal ON s.IdSocio = InteresReal.IdSocio
INNER JOIN @InteresesPagados interesPagado ON interesPagado.IdSocio = s.IdSocio
CROSS JOIN @UMA uma
WHERE s.IdSocio <> 0 AND
    interesPagado.RetencionISR <> 0
GROUP BY per.RFC,
         pf.CURP,
         pf.ApellidoPaterno,
         uma.UMA,
         s.IdSocio,
         interesPagado.InteresPagado,
         interesPagado.RetencionISR,
         per.Nombre
ORDER BY pf.ApellidoPaterno;

INSERT INTO dbo.tFELconstanciaRetenciones (IdEjercicio, IdPersona, Version, FechaExpedicion, Clave, Descripcion, EmisorRfc, EmisorRazonSocial, ReceptorNacionalRfc, ReceptorNacionalRazonSocial, ReceptorNacionalCurp, ReceptorNacionalidad, PeriodoMesInicial, PeriodoMesFinal, PeriodoEjercicio, MontoOperacion, MontoGravado, MontoExento, MontoRetenido, ImpuestoRetenidoBase, ImpuestoRetenidoImpuesto, ImpuestoRetenidoMontoRetenido, ImpuestoRetenidoTipoPago, IdPersonaEmisor)
SELECT IdEjercicio = dbo.fGETidEjercicio ('20211231'),
       Receptor.IdPersona,
       Version = '1.0',
       FechaExpedicion = CAST(CURRENT_TIMESTAMP AS DATE),
       Clave = '16',
       Descripcion = 'Intereses',
       Emisor.RFC,
       Emisor.Nombre,
       Receptor.RFC,
       Receptor.Nombre,
       ReceptorPf.CURP,
       ReceptorNacionalidad = 'Nacional',
       PeriodoMesInicial = Interes.[MesInicial],
       PeriodoMesFinal = Interes.MesFinal,
       Ejercicio = '2021',
       Interes.InteresNominal,
       MontoGravado = Interes.InteresNominal,
       MontoExento = Interes.InteresExento,
       MontoRetenido = Interes.[ISRretenido],
       ImpuestoRetenidoBase = Interes.InteresNominal,
       ImpuestoRetenidoImpuesto = '01', --ISR
       ImpuestoRetenidoMontoRetenido = Interes.[ISRretenido],
       ImpuestoRetenidoTipoPago = 'Pago definitivo',
       IdPersonaEmisor = 1
FROM dbo.#tabla Interes
INNER JOIN dbo.tSCSsocios Socio ON Socio.IdSocio = Interes.IdSocio
INNER JOIN dbo.tGRLpersonas Receptor ON Receptor.IdPersona = Socio.IdPersona
INNER JOIN dbo.tGRLpersonas Emisor ON Emisor.IdPersona = 1
LEFT JOIN dbo.tGRLpersonasFisicas ReceptorPf ON ReceptorPf.IdPersona = Receptor.IdPersona
ORDER BY Receptor.Nombre;

INSERT INTO dbo.tFELcomplementoConstanciaRetencionesIntereses (IdEjercicio, IdPersona, IdConstanciaRetencion, Version, SistemaFinanciero, Retiro, OperacionesDerivadas, MontoNominal, MontoReal, Perdida)
SELECT IdEjercicio = dbo.fGETidEjercicio ('20211231'),
       s.IdPersona,
       con.IdConstanciaRetencion,
       Version = '1.0',
       SistemaFinanciero = 'SI',
       Retiro = 'NO',
       OperacionesDerivadas = 'NO',
       Interes.InteresNominal,
       Interes.InteresReal,
       Perdida = 0
FROM dbo.#tabla Interes
INNER JOIN dbo.tSCSsocios s ON s.IdSocio = Interes.IdSocio
INNER JOIN dbo.tFELconstanciaRetenciones con ON con.IdPersona = s.IdPersona AND
                                                 con.IdEjercicio = dbo.fGETidEjercicio ('20211231');
