



DROP TABLE IF EXISTS #tACTactivos	
CREATE TABLE #tACTactivos ( [IdActivo] INT, [ValorOriginal] DECIMAL(18, 2), [Depreciacion] DECIMAL(18, 2), [DepreciacionAcumulada] DECIMAL(18, 2), [Remanente] DECIMAL(18, 2), [FechaAdquisicion] DATE, [FechaUltimaDepreciacion] DATE, [Periodos] INT, [PeriodosTranscurridos] INT, [PeriodosFaltantes] INT, IdPeriodoInicio INT )

INSERT INTO #tACTactivos(IdActivo, ValorOriginal, Depreciacion, DepreciacionAcumulada, Remanente, FechaAdquisicion, FechaUltimaDepreciacion, Periodos, PeriodosTranscurridos, PeriodosFaltantes, IdPeriodoInicio)
SELECT	Extendida.IdActivo,
		Extendida.ValorOriginal, 
		Depreciacion			= ROUND( (Extendida.ValorOriginal / Extendida.Periodos), 2),
		DepreciacionAcumulada	= ROUND( (Extendida.ValorOriginal / Extendida.Periodos) * Extendida.PeriodosTranscurridos, 2),
		Remanente				= ROUND( (Extendida.ValorOriginal - (Extendida.ValorOriginal / Extendida.Periodos) * Extendida.PeriodosTranscurridos), 2) ,
		FechaAdquisicion,
		Extendida.FechaUltimaDepreciacion,
		Extendida.Periodos,
		PeriodosTranscurridos = DATEDIFF(MONTH, Periodo.Inicio, FechaUltimaDepreciacion),
		PeriodosFaltantes = Extendida.Periodos - DATEDIFF(MONTH, Periodo.Inicio, FechaUltimaDepreciacion),
		Extendida.IdPeriodoInicio
	
FROM dbo.tACTactivosExtendida Extendida WITH(NOLOCK)
INNER JOIN dbo.tCTLperiodos	    Periodo WITH(NOLOCK) ON Extendida.IdPeriodoInicio = Periodo.IdPeriodo
WHERE Extendida.IdActivo > 0 AND Extendida.IdEstatusDepreciacion = 98
 AND IdPeriodoInicio <= dbo.fGETidPeriodo(DATEADD(MONTH, -1, CURRENT_TIMESTAMP))

SELECT *
FROM #tACTactivos



