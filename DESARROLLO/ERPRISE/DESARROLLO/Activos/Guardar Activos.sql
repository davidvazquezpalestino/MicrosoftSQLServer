USE iERP_CPA;
GO

BEGIN TRANSACTION 

IF OBJECT_ID('tempdb.dbo.#DepreciasionPeriodo', 'U') IS NOT NULL
    DROP TABLE #DepreciasionPeriodo;
CREATE TABLE #DepreciasionPeriodo
(
    [IdActivo] INT,
    [IdPeriodo] INT,
    [IdTipoDmetodo] INT,
    [Numero] INT,
    [ValorOriginal] DECIMAL(18, 2),
    [ValorActual] DECIMAL(38, 2),
    [DepreciacionAcumulada] DECIMAL(38, 2),
    [DepreciacionCalculada] DECIMAL(18, 2),
    [Depreciacion] DECIMAL(18, 2),
    [ValorRemanente] DECIMAL(38, 2),
    [VidaTotal] INT,
    [VidaActual] INT,
    [VidaDepreciacionAcumulada] INT,
    [IdEstatus] INT
);



DECLARE @IdPeriodo INT=151;
INSERT INTO #DepreciasionPeriodo( IdActivo, IdPeriodo, IdTipoDmetodo, Numero, ValorOriginal, ValorActual,
                                  DepreciacionAcumulada, DepreciacionCalculada, Depreciacion, ValorRemanente,
                                  VidaTotal, VidaActual, VidaDepreciacionAcumulada, IdEstatus )
SELECT ext.IdActivo,
       IdPeriodo=151,
       IdTipoDmetodo=ext.IdTipoDmetodo,
       Numero=depre.Numero,
       
	   ValorOriginal=depre.ValorOriginal,
       ValorActual = depre.ValorRemanente - ISNULL(depre.Depreciacion, ext.DepreciacionCalculada),

       DepreciacionAcumulada = depre.DepreciacionAcumulada +  ISNULL(depre.Depreciacion, ext.DepreciacionCalculada),
       DepreciacionCalculada = ISNULL(depre.Depreciacion, ext.DepreciacionCalculada),
       Depreciacion =  ISNULL(depre.Depreciacion, ext.DepreciacionCalculada),
	   
	   ValorRemanente = depre.ValorRemanente,

	   VidaTotal = ext.Periodos,
	   VidaActual = depre.Numero,
	   VidaDepreciacionAcumulada = ext.Periodos,	   
	   IdEstatus = 1

FROM dbo.tACTactivosExtendida ext
LEFT JOIN dbo.tACTinformacionDepreciacion inf ON inf.IdActivo=ext.IdActivo AND ext.IdPeriodoUltimaDepreciasion = 151
LEFT JOIN dbo.vACTperiodosDepreciados depre ON depre.IdActivo=ext.IdActivo
WHERE ext.IdActivo > 0 AND inf.IdActivo IS NULL AND ext.ValorRemanente != 0;




INSERT INTO tACTinformacionDepreciacion(IdActivo, IdPeriodo, IdTipoDmetodo, Numero, ValorOriginal, ValorActual, DepreciacionAcumulada, DepreciacionCalculada, Depreciacion, ValorRemanente, VidaTotal, VidaActual, VidaDepreciacionAcumulada, IdEstatus)
SELECT IdActivo, IdPeriodo, IdTipoDmetodo, Numero, ValorOriginal, ValorActual, DepreciacionAcumulada, DepreciacionCalculada, Depreciacion, ValorRemanente, VidaTotal, VidaActual, VidaDepreciacionAcumulada, IdEstatus
FROM #DepreciasionPeriodo depre
WHERE NOT EXISTS (SELECT 1 FROM dbo.tACTinformacionDepreciacion info WHERE depre.IdActivo = info.IdActivo AND depre.IdPeriodo = info.IdPeriodo);


UPDATE ext SET ext.IdPeriodoUltimaDepreciasion = 151, ext.ValorActual = depre.ValorActual, ext.ValorRemanente = depre.ValorRemanente, ext.PeriodosTranscurridos = depre.Numero
FROM tACTactivosExtendida ext
INNER JOIN tACTinformacionDepreciacion info ON info.IdActivo = ext.IdActivo 
INNER JOIN #DepreciasionPeriodo depre ON depre.IdPeriodo = info.IdPeriodo AND depre.IdActivo = ext.IdActivo
WHERE info.IdPeriodo = 151
GO


SELECT *
FROM dbo.tACTinformacionDepreciacion
WHERE IdPeriodo = 151

COMMIT TRANSACTION 