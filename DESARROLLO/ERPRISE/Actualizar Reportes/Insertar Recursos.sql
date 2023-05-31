INSERT INTO tCTLinformesVersion (IdInforme, NombreArchivo, TipoReporte)
SELECT
	IdInforme,
	Reporte,
	TipoReporte = 'Formatos'
FROM tctlinformes i
WHERE idinforme <> 0
AND IdEstatus = 1
AND NOT EXISTS (SELECT IdInforme FROM tCTLinformesVersion iv WHERE i.IdInforme = iv.IdInforme)

INSERT INTO tCTLinformesVersion (IdRecurso, NombreArchivo, TipoReporte)
SELECT
	IdRecurso,
	ObjetoDesktop,
	TipoReporte = 'Informes'
FROM tCTLrecursos r
WHERE IdTipoD = 3
AND IdEstatus = 1 AND NOT EXISTS (SELECT IdRecurso FROM tCTLinformesVersion iv WHERE iv.IdRecurso = r.IdRecurso)


