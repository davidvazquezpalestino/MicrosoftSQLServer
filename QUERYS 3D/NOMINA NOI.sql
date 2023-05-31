UPDATE PercepcionDeduccion
SET EMPLEADO = PercepcionDeduccion.CONCEPTO
FROM dbo.PercepcionesDeducciones PercepcionDeduccion
INNER JOIN dbo.vPERempleados e ON PercepcionDeduccion.concepto = e.Codigo
WHERE ISNULL (TRY_CAST(PercepcionDeduccion.CONCEPTO AS INT), 0) <> 0;


DELETE PercepcionDeduccion
FROM dbo.PercepcionesDeducciones PercepcionDeduccion
WHERE EMPLEADO IS NULL AND PATINDEX ('%[^PD0-9]%', CONCEPTO) <> 0;

DELETE FROM dbo.PercepcionesDeducciones
WHERE CONCEPTO IS NULL AND EMPLEADO IS NULL AND F3 IS NULL AND PERCEPCIONES IS NULL AND [PERC# GRAVADA] IS NULL AND [PERC# EXENTA] IS NULL AND [PERC# OTROS] IS NULL AND DEDUCCIONES IS NULL AND OBLIGACIONES IS NULL;

DELETE FROM dbo.PercepcionesDeducciones
WHERE EMPLEADO IS NULL AND CONCEPTO IS NULL AND F3 IS NULL;

UPDATE PercepcionDeduccion
SET F3 = PERCEPCIONES
FROM dbo.PercepcionesDeducciones PercepcionDeduccion
WHERE EMPLEADO IS NOT NULL;

UPDATE PercepcionDeduccion
SET PERCEPCIONES = 0
FROM dbo.PercepcionesDeducciones PercepcionDeduccion
WHERE EMPLEADO IS NOT NULL;

UPDATE PercepcionDeduccion
SET PERCEPCIONES = REPLACE (PERCEPCIONES, ',', ''),
    [PERC# GRAVADA] = REPLACE ([PERC# GRAVADA], ',', ''),
    [PERC# EXENTA] = REPLACE ([PERC# EXENTA], ',', ''),
    [PERC# OTROS] = REPLACE ([PERC# OTROS], ',', ''),
    DEDUCCIONES = REPLACE (DEDUCCIONES, ',', '')
FROM dbo.PercepcionesDeducciones PercepcionDeduccion;

ALTER TABLE dbo.PercepcionesDeducciones ALTER COLUMN PERCEPCIONES DECIMAL(18, 2);
ALTER TABLE dbo.PercepcionesDeducciones ALTER COLUMN [PERC# GRAVADA] DECIMAL(18, 2);
ALTER TABLE dbo.PercepcionesDeducciones ALTER COLUMN [PERC# EXENTA] DECIMAL(18, 2);
ALTER TABLE dbo.PercepcionesDeducciones ALTER COLUMN [PERC# OTROS] DECIMAL(18, 2);
ALTER TABLE dbo.PercepcionesDeducciones ALTER COLUMN DEDUCCIONES DECIMAL(18, 2);
ALTER TABLE dbo.PercepcionesDeducciones ALTER COLUMN OBLIGACIONES DECIMAL(18, 2);

DELETE FROM dbo.PercepcionesDeducciones
WHERE CONCEPTO IS NULL AND ( ISNULL ([PERC# GRAVADA], 0) + ISNULL ([DEDUCCIONES], 0)) > 0;

DELETE FROM dbo.PercepcionesDeducciones
WHERE CONCEPTO IS NULL;

SELECT EMPLEADO = ISNULL (EMPLEADO, ''),
    CONCEPTO = COALESCE (CONCEPTO, ''),
    F3 = COALESCE (F3, ''),
    PERCEPCIONES = ISNULL (PERCEPCIONES, 0),
    [PERC# GRAVADA] = ISNULL ([PERC# GRAVADA], 0),
    [PERC# EXENTA] = ISNULL ([PERC# EXENTA], 0),
    [PERC# OTROS] = ISNULL ([PERC# OTROS], 0),
    DEDUCCIONES = ISNULL (DEDUCCIONES, 0),
    OBLIGACIONES = ISNULL (OBLIGACIONES, 0),
    PERIODO = ISNULL (PERIODO, '')
FROM dbo.PercepcionesDeducciones PercepcionDeduccion;


DROP TABLE dbo.PercepcionesDeducciones