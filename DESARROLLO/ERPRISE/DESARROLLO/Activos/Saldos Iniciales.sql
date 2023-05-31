




IF NOT EXISTS (SELECT name FROM tempdb.sys.columns WHERE object_id=OBJECT_ID('tempdb.dbo.##activos')AND name='MetodoDepreciacion')
    ALTER TABLE tempdb.dbo.##activos ADD MetodoDepreciacion VARCHAR(100) DEFAULT 'LINEAL';
GO

DECLARE @IdTipoDActivo INT = 2207; -- ACTIVOS DIFERIDOS


DELETE FROM ##activos
WHERE IdentificadorActivo IS NULL;

IF OBJECT_ID('tempdb.dbo.#ActivosIniciales', 'U') IS NOT NULL
    DROP TABLE #ActivosIniciales;

IF OBJECT_ID('tempdb.dbo.#TiposDClasificacion', 'U') IS NOT NULL
    DROP TABLE #TiposDClasificacion;

CREATE TABLE #ActivosIniciales
(
    IdActivo INT,
    IdBienServicio INT,
    Codigo VARCHAR(32),
    Descripcion VARCHAR(1024),
    DescripcionLarga VARCHAR(1024),
    IdSucursal INT,
    IdCentroCostos INT,
    IdEstatus INT,
    Referencia VARCHAR(32),
    IdDivision INT,
    IdEstructuraContableE INT,
    IdTipoDActivo INT,
    IdTipoDClasificacion INT,
    FechaAdquisicion DATE,
    ValorOriginal DECIMAL(18, 2),
    ValorActual DECIMAL(18, 2),
    ValorRemanente DECIMAL(18, 2),
    IdentificadorPersonaProveedor VARCHAR(128),
    FolioFactura VARCHAR(64),
    NumeroSerie VARCHAR(64),
    INPCadquisicion VARCHAR(64),
    Vigencia DATE,
    IdTipoDmetodo INT,
    FactorAnual DECIMAL(18, 2),
    Periodos DECIMAL(18, 2),
    PeriodosTranscurridos INT,
    PeriodosFaltantes DECIMAL(18, 2),
    IdPeriodoInicio INT,
    DepreciacionAcumulada DECIMAL(18, 2),
    DepreciacionCalculada DECIMAL(18, 2),
    IdEstatusDepreciacion INT,
    FechaUltimaDepreciacion DATE,
    Mensaje VARCHAR(1024)
);


CREATE TABLE #TiposDClasificacion
(
    IdTipoD INT,
    Codigo VARCHAR(20),
    Descripcion VARCHAR(250),
    IdTipoE INT
);

INSERT INTO #TiposDClasificacion
(
    IdTipoD,
    Codigo,
    Descripcion,
    IdTipoE
)
SELECT IdTipoD,
       Codigo,
       Descripcion,
       IdTipoE
FROM dbo.tCTLtiposD
WHERE IdTipoE = 329;

INSERT INTO #ActivosIniciales
(
    IdActivo,
    IdBienServicio,
    Codigo,
    Descripcion,
    DescripcionLarga,
    IdSucursal,
    IdCentroCostos,
    IdEstatus,
    Referencia,
    IdDivision,
    IdEstructuraContableE,
    IdTipoDActivo,
    IdTipoDClasificacion,
    FechaAdquisicion,
    ValorOriginal,
    ValorActual,
    ValorRemanente,
    IdentificadorPersonaProveedor,
    FolioFactura,
    NumeroSerie,
    INPCadquisicion,
    Vigencia,
    IdTipoDmetodo,
    FactorAnual,
    Periodos,
    PeriodosTranscurridos,
    PeriodosFaltantes,
    IdPeriodoInicio,
    DepreciacionAcumulada,
    DepreciacionCalculada,
    IdEstatusDepreciacion,
    FechaUltimaDepreciacion
)
SELECT -- Encabezado
    IdActivo = ROW_NUMBER() OVER (ORDER BY Activo.Codigo),
    Bien.IdBienServicio,
    Activo.Codigo,
    Activo.Descripcion,
    Activo.DescripcionLarga,
    Sucursal.IdSucursal,
    Sucursal.IdCentroCostos,
    Estatus.IdEstatus,
    Referencia,
    Division.IdDivision,
    EstructuraContable.IdEstructuraContableE,
                                             
    Activo.IdTipoDActivo,
    Activo.IdTipoDClasificacion,
    Activo.FechaAdquisicion,
    Activo.ValorOriginal,
    Activo.ValorActual,
    Activo.ValorRemanente,
    IdentificadorPersonaProveedor,
    FolioFactura,
    NumeroSerie,
    INPCadquisicion,
    Vigencia,
    IdTipoDmetodo = TipoMetodo.IdTipoD,
    FactorAnual,
    Activo.Periodos,
    PeriodosTranscurridos,
    PeriodosFaltantes,
    IdPeriodoInicio = 0,
    DepreciacionAcumulada,
    DepreciacionCalculada,
    IdEstatusDepreciacion = Estatus.IdEstatus, ---- Estatus depreciasión 
    FechaUltimaDepreciacion
FROM
(
    SELECT Articulo,
           Codigo = act.IdentificadorActivo,
           act.Descripcion,
           act.DescripcionLarga,
           act.Sucursal,
           act.Estatus,
           act.Referencia,
           Division,
           EstructuraContable = act.EstructuraContable,
           IdTipoDActivo = @IdTipoDActivo,
           IdTipoDClasificacion = Clasificacion.IdTipoD,
           FechaAdquisicion = act.FechaAdquisicion,
           ValorOriginal = ISNULL(act.ValorOriginal, 0),
           ValorActual = ISNULL(act.ValorOriginal, 0) - ISNULL(act.ValorRemanente, 0),
           ValorRemanente = ISNULL(act.ValorRemanente, 0),
           IdentificadorPersonaProveedor = act.IdentificadorPersonaProveedor,
           FolioFactura = act.FolioFactura,
           NumeroSerie = act.NumeroSerie,
           INPCadquisicion = act.INPCadquisicion,
           Vigencia = act.Vigencia,         
		   MetodoDepreciacion = ISNULL(MetodoDepreciacion, 'LINEAL'),
           FactorAnual = ISNULL(FactorAnual, 0),
           Periodos = ISNULL(act.PeriodosTranscurridos, 0) + ISNULL(PeriodosFaltantes, 0),
           PeriodosTranscurridos = PeriodosTranscurridos,
           PeriodosFaltantes = PeriodosFaltantes,
           DepreciacionAcumulada = ISNULL(ValorAcumulado, 0),
           DepreciacionCalculada = ISNULL(act.[DepreciaciónMensual], 0),
           FechaUltimaDepreciacion = act.FechaUltimaDepreciacion
    FROM ##activos act
    INNER JOIN #TiposDClasificacion Clasificacion ON Clasificacion.Descripcion = act.SubTipoFijo
) Activo
INNER JOIN dbo.tGRLbienesServicios Bien WITH (NOLOCK) ON Activo.Articulo COLLATE Modern_Spanish_CI_AI = Bien.Codigo COLLATE Modern_Spanish_CI_AI
INNER JOIN dbo.tCTLsucursales Sucursal ON Activo.Sucursal = Sucursal.Codigo
INNER JOIN dbo.tCTLestatus Estatus ON Activo.Estatus = Estatus.Descripcion
INNER JOIN dbo.tCNTdivisiones Division ON Activo.Division = Division.Codigo
INNER JOIN dbo.tCNTestructurasContablesE EstructuraContable ON Activo.EstructuraContable = EstructuraContable.Codigo
INNER JOIN dbo.tCTLtiposD TipoMetodo ON TipoMetodo.Descripcion = ISNULL(Activo.MetodoDepreciacion, 'LINEAL');


UPDATE x
SET x.Mensaje = 'REVISAR EL ARTÍCULO'
FROM #ActivosIniciales x
WHERE IdBienServicio = 0;

UPDATE x
SET x.Mensaje = 'REVISAR EL CENTRO DE COSTOS'
FROM #ActivosIniciales x
WHERE IdCentroCostos = 0;

UPDATE x
SET x.Mensaje = 'REVISAR LA DIVISIÓN DEL ACTIVO'
FROM #ActivosIniciales x
WHERE IdDivision = 0;

UPDATE x
SET x.Mensaje = 'REVISAR EL ESTATUS DEL ACTIVO'
FROM #ActivosIniciales x
WHERE IdEstatusDepreciacion = 0;

UPDATE x
SET x.Mensaje = 'REVISAR LA ESTRUCTURA CONTABLE DEL ACTIVO'
FROM #ActivosIniciales x
WHERE IdEstructuraContableE = 0;

UPDATE x
SET x.Mensaje = 'REVISAR LA SUCURSAL DEL ACTIVO'
FROM #ActivosIniciales x
WHERE IdSucursal = 0;

UPDATE x
SET x.Mensaje = 'REVISAR EL TIPO DE ACTIVO'
FROM #ActivosIniciales x
WHERE IdTipoDActivo = 0;


UPDATE x
SET x.Mensaje = 'REVISAR LA CLASIFICASION DEL ACTIVO'
FROM #ActivosIniciales x
WHERE IdTipoDClasificacion = 0;

UPDATE x
SET x.Mensaje = 'REVISAR EL MÉTODO DE DEPRECIASION DEL ACTIVO'
FROM #ActivosIniciales x
WHERE IdTipoDmetodo = 0;


UPDATE Activo
SET Activo.Mensaje = 'REVISAR LOS CODIGOS ESTÁN REPETIDOS'
FROM #ActivosIniciales Activo
INNER JOIN
(
    SELECT Codigo,
           IdSucursal
    FROM #ActivosIniciales
    GROUP BY Codigo,
             IdSucursal
    HAVING COUNT(*) > 1
) Repetidos ON Repetidos.Codigo = Activo.Codigo;






INSERT INTO dbo.tACTActivosIniciales
(
    IdBienServicio,
    Codigo,
    Descripcion,
    DescripcionLarga,
    IdSucursal,
    IdCentroCostos,
    IdEstatus,
    Referencia,
    IdDivision,
    IdEstructuraContableE,
    IdTipoDActivo,
    IdTipoDClasificacion,
    FechaAdquisicion,
    ValorOriginal,
    ValorActual,
    ValorRemanente,
    IdentificadorPersonaProveedor,
    FolioFactura,
    NumeroSerie,
    INPCadquisicion,
    Vigencia,
    IdTipoDmetodo,
    FactorAnual,
    Periodos,
    PeriodosTranscurridos,
    PeriodosFaltantes,
    IdPeriodoInicio,
    DepreciacionAcumulada,
    DepreciacionCalculada,
    IdEstatusDepreciacion,
    FechaUltimaDepreciacion,
    Mensaje
)
SELECT IdBienServicio,
       Codigo,
       Descripcion,
       DescripcionLarga,
       IdSucursal,
       IdCentroCostos,
       IdEstatus,
       Referencia,
       IdDivision,
       IdEstructuraContableE,
       IdTipoDActivo,
       IdTipoDClasificacion,
       FechaAdquisicion,
       ValorOriginal,
       ValorActual,
       ValorRemanente,
       IdentificadorPersonaProveedor,
       FolioFactura,
       NumeroSerie,
       INPCadquisicion,
       Vigencia,
       IdTipoDmetodo,
       FactorAnual,
       Periodos,
       PeriodosTranscurridos,
       PeriodosFaltantes,
       IdPeriodoInicio,
       DepreciacionAcumulada,
       DepreciacionCalculada,
       IdEstatusDepreciacion,
       FechaUltimaDepreciacion,
       Mensaje
FROM #ActivosIniciales a
WHERE NOT EXISTS
(
    SELECT 1 FROM tACTActivosIniciales b WHERE b.Codigo = a.Codigo 
);

UPDATE x
SET x.FechaAdquisicion = DATEADD(MONTH, -PeriodosTranscurridos, '20190731')
FROM tACTActivosIniciales x
WHERE x.FactorAnual IS NULL AND x.IdEstatus = 98;

UPDATE x
SET x.FactorAnual = (1 * 12) / x.Periodos
FROM tACTActivosIniciales x
WHERE x.FactorAnual IS NULL AND x.IdEstatus = 98;

UPDATE x
SET x.IdTipoDmetodo = 2616
FROM dbo.tACTActivosIniciales x
WHERE IdEstatusDepreciacion = 99;



DECLARE @Afectar BIT = 0;
IF @Afectar = 1
BEGIN

    SET IDENTITY_INSERT dbo.tACTactivos ON;

    INSERT INTO dbo.tACTactivos
    (
        IdActivo,
        IdBienServicio,
        Codigo,
		Descripcion,
        DescripcionLarga,
        IdSucursal,
        IdCentroCostos,
        IdEstatus,
        IdUsuarioAlta,
        Alta,
        Referencia,
        IdDivision,
        IdEstructuraContableE
    )
    SELECT a.IdActivo,
           a.IdBienServicio,
           a.Codigo,
           a.Descripcion,
		   a.DescripcionLarga,
           a.IdSucursal,
           a.IdCentroCostos,
           IdEstatus = 1,
           IdUsuarioAlta = -1,
           CURRENT_TIMESTAMP,
           a.Referencia,
           a.IdDivision,
           a.IdEstructuraContableE
    FROM tACTActivosIniciales a
    WHERE NOT EXISTS
    (
        SELECT 1 FROM dbo.tACTactivos b WHERE a.Codigo = b.Codigo AND a.IdSucursal = b.IdSucursal
    );
	
    SET IDENTITY_INSERT dbo.tACTactivos OFF;

	INSERT INTO dbo.tACTactivosExtendida(IdActivo, IdTipoDActivo, IdTipoDClasificacion, FechaAdquisicion, ValorOriginal, ValorActual, ValorRemanente, FolioFactura, NumeroSerie, INPCadquisicion, Vigencia, IdTipoDmetodo, FactorAnual, Periodos, PeriodosTranscurridos, IdPeriodoInicio, DepreciacionAcumulada, DepreciacionCalculada, IdEstatusDepreciacion, FechaUltimaDepreciacion, IdPeriodoUltimaDepreciasion)

	SELECT IdActivo, IdTipoDActivo, IdTipoDClasificacion, ISNULL(FechaAdquisicion, '19000101'), ValorOriginal, ValorActual, ValorRemanente, FolioFactura, NumeroSerie, INPCadquisicion, Vigencia, IdTipoDmetodo, FactorAnual, Periodos, ISNULL(PeriodosTranscurridos, 0), IdPeriodoInicio, DepreciacionAcumulada, DepreciacionCalculada, IdEstatusDepreciacion, FechaUltimaDepreciacion,  IdPeriodoUltimaDepreciasion = 150
	FROM dbo.tACTActivosIniciales a
	WHERE NOT EXISTS (SELECT 1 FROM dbo.tACTactivosExtendida b WHERE b.IdActivo = a.IdActivo)

	INSERT INTO dbo.tACTinformacionDepreciacion(IdActivo, IdPeriodo, IdTipoDmetodo, Numero, ValorOriginal, ValorActual, DepreciacionAcumulada, DepreciacionCalculada, Depreciacion, ValorRemanente, VidaTotal, VidaActual, IdEstatus, SaldoInicial)
	SELECT IdActivo, IdPeriodo = 150, IdTipoDmetodo, PeriodosTranscurridos, ValorOriginal, ValorActual, DepreciacionAcumulada, DepreciacionCalculada, DepreciacionCalculada, ValorRemanente, Periodos, PeriodosTranscurridos, IdEstatus= 1, 1
	FROM dbo.tACTActivosIniciales a
	WHERE NOT EXISTS (SELECT * FROM tACTinformacionDepreciacion b WHERE b.IdActivo = a.IdActivo)

END;


--TRUNCATE TABLE dbo.tACTActivosIniciales
--DELETE FROM dbo.tACTinformacionDepreciacion WHERE IdInformacionDepreciacion > 0
--DBCC CHECKIDENT(tACTinformacionDepreciacion, RESEED, 0)
--DELETE FROM dbo.tACTactivosExtendida WHERE IdActivoExt > 0
--DELETE FROM dbo.tACTactivos WHERE IdActivo > 0

SELECT * 
FROM tACTactivos

